#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable
  include Adjustable

  #---
  # Store is the current store, store portal is an optional store id
  # for the portal store the originating hostname points to.
  belongs_to :store
  belongs_to :store_portal, class_name: 'Store'

  # User created the order, and is usually the customer too.
  belongs_to :user, required: true
  belongs_to :customer, class_name: 'User', inverse_of: :customer_orders
  accepts_nested_attributes_for :customer

  belongs_to :order_type
  delegate :payment_gateway_class, to: :order_type

  default_scope { where(cancelled_at: nil) }

  scope :at, -> (store) { where(store: store) }
  scope :for, -> (customer) { where(customer: customer) }
  scope :targeted, -> { where('user_id != customer_id') }

  # Current orders are completed, not yet approved orders.
  scope :current, -> { where.not(completed_at: nil).where(approved_at: nil) }

  # Pending orders are approved, not yet concluded orders.
  scope :pending, -> { where.not(approved_at: nil).where(concluded_at: nil) }

  # Complete orders, approved or not.
  scope :complete, -> { where.not(completed_at: nil) }

  # Incomplete orders is the scope for shopping carts.
  scope :incomplete, -> { where(completed_at: nil) }

  # Approved orders.
  scope :approved, -> { where.not(approved_at: nil) }

  # Concluded orders.
  scope :concluded, -> { where.not(concluded_at: nil) }

  # Cancelled orders.
  scope :cancelled, -> { unscope(where: :cancelled_at).where.not(cancelled_at: nil) }

  # Orders not concluded or concluded recently for timeline data.
  scope :topical, -> { where('concluded_at IS NULL OR concluded_at > ?', 2.weeks.ago) }

  #---
  validates :customer, presence: true, on: :update
  validates :customer_name, presence: true, on: :update
  validates :customer_email, presence: true, on: :update
  validates :customer_phone, presence: true, on: :update

  #---
  # This attribute allows adding products en masse
  # through a string of comma-separated ids.
  attr_accessor :product_ids_string

  # This attribute allows specifying a group for an order
  # created from scratch with nested customer data.
  attr_accessor :group_id

  # This attribute allows admins to finalize an order,
  # both completing and approving it at once.
  attr_accessor :is_final

  #---
  # Approve the order when approved_at first gets a value.
  after_save :approve!, if: -> (order) { order.approved_at_changed?(from: nil) }

  # Conclude the order when concluded_at first gets a value.
  after_save :conclude!, if: -> (order) { order.concluded_at_changed?(from: nil) }

  # Cancel the order when cancelled_at first gets a value.
  after_save :cancel!, if: -> (order) { order.cancelled_at_changed?(from: nil) }

  #---
  # Statuses that can be queried against.
  def self.statuses
    [:current, :pending, :concluded, :cancelled, :incomplete]
  end

  #---
  # Define methods to use archived copies of order attributes if the order
  # is concluded, otherwise go through the associations. See #archive! below.
  %w[store_name user_name user_email user_phone].each do |method|
    association, association_method = method.split('_', 2)
    define_method(method.to_sym) do
      concluded? ? self[method] : send(association).send(association_method)
    end
  end
  def order_type_name
    concluded? ? self[:order_type_name] : order_type.name
  end

  # Orders targeted at another customer, not the user herself.
  # This also indicates the order is considered to be a quote
  # when incomplete.
  def targeted?
    user != customer
  end

  # Order source group is independent of order type.
  def source
    customer.group(store)
  end

  # Pricing applied to this order, based on source group.
  def customer_pricing
    Appraiser::Product.new(source)
  end

  # Order destination depends on the order type since there may be
  # multiple order types to choose from at checkout.
  delegate :destination, to: :order_type

  # Finds the order types available to this order. These are the outgoing
  # order types for the source group, excluding those that are not suitable
  # for one or more products present in the order items.
  def available_order_types
    shipping_requirement = requires_shipping?
    return source.outgoing_order_types if shipping_requirement.nil?
    source.outgoing_order_types.where(has_shipping: shipping_requirement)
  end

  # Changing the order contents is allowed for incomplete orders,
  # targeted orders, but they must not be concluded or cancelled.
  def editable_items?
    incomplete? || targeted? && !(concluded? || cancelled?)
  end

  def current?
    complete? && !approved?
  end

  def complete?
    completed_at.present?
  end

  def incomplete?
    !complete?
  end

  def pending?
    approved? && !concluded?
  end

  def cancelled?
    cancelled_at.present?
  end

  def concludable?
    pending? && !cancelled? && (!track_shipments? || fully_shipped?)
  end

  def approved?
    !!approved_at.present?
  end

  def concluded?
    !!concluded_at.present?
  end

  # Order should complete when it reaches complete phase at checkout
  # but hasn't been completed yet.
  def should_complete?
    incomplete? && checkout_phase == :complete
  end

  # Completing an order assigns it a number, archives it, sends
  # order receipt/acknowledge, and triggers an XML export job.
  def complete!(acknowledge = true)
    assign_number!
    archive!
    email(has_payment? ? :receipt : :acknowledge, customer_string) if acknowledge
    export_xml
  end

  def assign_number!
    Order.with_advisory_lock('order_numbering') do
      numbered = store.orders.complete.where.not(number: nil).order(:completed_at)
      current_max = if numbered.any?
        numbered.last.number
      else
        store.order_sequence.presence || 0
      end
      update(number: current_max.succ, completed_at: Time.current)
    end
  end

  # Archives the order and its items to permanently record data
  # that is subject to change.
  def archive!
    transaction do
      update(
        store_name: store.name,
        user_name: user.try(:name),
        user_email: user.try(:email),
        user_phone: user.try(:phone),
        order_type_name: order_type.name
      )
      order_items.each do |item|
        item.archive!
      end
    end
  end

  def has_installation?
    order_type.present? && order_type.has_installation?
  end

  def paid?
    balance <= 0.to_money
  end

  def balance
    grand_total_with_tax - payments.map(&:amount).sum
  end

  # Grand total for the given items (or whole order), without tax.
  def grand_total_sans_tax(items = order_items)
    items.map { |item| item.grand_total_sans_tax || 0.to_money }.sum + adjustments_sans_tax
  end

  # Same as above, with tax.
  def grand_total_with_tax(items = order_items)
    items.map { |item| item.grand_total_with_tax || 0.to_money }.sum + adjustments_with_tax
  end

  # Total tax for the given items.
  def tax_total(items = order_items)
    items.map { |item| item.tax_total || 0.to_money }.sum
  end

  def adjustments_sans_tax
    adjustments.map { |a| a.amount_sans_tax || 0.to_money }.sum
  end

  def adjustments_with_tax
    adjustments.map { |a| a.amount_with_tax || 0.to_money }.sum
  end

  # Grand total for exported orders.
  def grand_total_for_export(items = order_items)
    items.map { |item|
      (item.subtotal_for_export || 0.to_money) + item.adjustments_sans_tax
    }.sum + adjustments_sans_tax
  end

  # Order phase in the checkout process. This is included in the JSON
  # representation for checkout.coffee to reveal the corresponding form
  # elements.
  def checkout_phase
    return :address  if !valid?
    return :shipping if has_shipping? && shipments.empty?
    return :payment  if has_payment? && !paid?
    return :complete
  end

  # Notify users with order_notify role in the destination group.
  def notified_users
    destination.users.with_role(:order_notify, store)
  end

  def email(message, to, items = nil, options = {})
    options.reverse_merge!(
      bcc: true,
      pricing: true
    )
    if store.disable_mail?
      logger.info "Sending of e-mail is currently disabled, aborting"
      return false
    else
      OrderMailer.send(message, self, to, items, options).deliver_later
    end
  end

  private
    # Approving an order prepares its initial transfer by creating it
    # attached to the initial shipment, which in turn is created if needed.
    # The appropriate parties are sent email notifications.
    def approve!
      reload # to clear changes and prevent a callback loop
      if has_payment?
        email(:processing, customer_string, nil, bcc: false)
      else
        email(:confirmation, customer_string, nil, bcc: false)
        email(:confirmation, contact_string, nil, bcc: false, pricing: false) if has_contact_info?
      end
      items_by_vendor.each do |vendor, items|
        vendor.notified_users.each do |user|
          email(:notification, user.to_s, items, bcc: false, pricing: false)
        end
      end
      create_initial_transfer! if track_shipments?
      true
    end

    # Concluding an order creates asset entries for it.
    # A notification of shipment is sent.
    def conclude!
      reload # to clear changes and prevent a callback loop
      email(:shipment, customer_string, nil, bcc: false)
      email(:shipment, contact_string, nil, bcc: false, pricing: false) if has_contact_info?
      OrderReportRow.create_from(self)
      CustomerAsset.create_from(self)
      true
    end

    # Cancelling an order rolls back any changes made earlier by
    # backtracking its life cycle from conclusion to creation.
    def cancel!
      reload # to clear changes and prevent a callback loop
      if concluded?
        CustomerAsset.cancel_entries_from(self)
        OrderReportRow.cancel_entries_from(self)
      end
      total_for_real_items = grand_total_with_tax(order_items.real)
      if has_payment? && paid?
        payments.create(amount: -total_for_real_items)
      end
      if track_shipments?
        shipments.active.each do |shipment|
          shipment.cancel!
        end
      end
      true
    end

    # Perform XML export if specified by order type, and
    # store settings have a path defined.
    def export_xml
      if order_type.is_exported? && store.order_xml_path.present?
        OrderExportJob.perform_later(self, store.order_xml_path)
      end
    end
end

require_dependency 'order/contents'
require_dependency 'order/shipping_and_billing'
require_dependency 'order/presentation'
