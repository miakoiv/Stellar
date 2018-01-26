#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable

  #---
  belongs_to :store
  belongs_to :user

  # Shipping and billing addresses have country associations.
  belongs_to :shipping_country, class_name: 'Country', foreign_key: :shipping_country_code
  belongs_to :billing_country, class_name: 'Country', foreign_key: :billing_country_code

  belongs_to :order_type
  delegate :is_rfq?, :is_quote?, to: :order_type
  delegate :payment_gateway_class, to: :order_type

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_items
  has_many :payments, dependent: :destroy, inverse_of: :order
  has_many :shipments, dependent: :destroy, inverse_of: :order

  default_scope { where(cancelled_at: nil) }

  scope :at, -> (store) { where(store: store) }

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

  def self.statuses
    [:current, :pending, :concluded, :cancelled]
  end

  # Orders that are not concluded or have been concluded not longer than
  # one week ago are topical. This is used for timeline data.
  scope :topical, -> { where('concluded_at IS NULL OR concluded_at > ?', 2.weeks.ago) }

  scope :has_shipping, -> { joins(:order_type).merge(OrderType.has_shipping) }

  #---
  validates :customer_name, presence: true, on: :update
  validates :customer_email, presence: true, on: :update
  validates :customer_phone, presence: true, on: :update

  validates :shipping_address, :shipping_postalcode, :shipping_city, :shipping_country_code, presence: true, on: :update,
    if: :has_shipping?

  validates :billing_address, :billing_postalcode, :billing_city, :billing_country_code, presence: true, on: :update,
    if: :billing_address_required?

  #---
  # This attribute allows adding products en masse
  # through a string of comma-separated ids.
  attr_accessor :product_ids_string

  #---
  before_validation :copy_billing_address, if: :should_copy_billing_address?
  before_validation :ensure_valid_countries, on: :update

  # Approve the order when approved_at first gets a value.
  after_save :approve!, if: -> (order) { order.approved_at_changed?(from: nil) }

  # Conclude the order when concluded_at first gets a value.
  after_save :conclude!, if: -> (order) { order.concluded_at_changed?(from: nil) }

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

  # Order source group is independent of order type.
  def source
    user.group(store)
  end

  # Order destination depends on the order type since there may be
  # multiple order types to choose from at checkout.
  delegate :destination, to: :order_type

  # Allow adding and editing order items on quotations only.
  def editable_items?
    is_quote?
  end

  # Notify users with order_notify role in the destination group.
  def notified_users
    destination.users.with_role(:order_notify, store)
  end

  def customer_string
    "#{customer_name} <#{customer_email}>"
  end

  def has_contact_info?
    contact_person.present? && contact_email.present?
  end

  def contact_string
    has_contact_info? ? "#{contact_person} <#{contact_email}>" : nil
  end

  def approved?
    !!approved_at.present?
  end

  def concluded?
    !!concluded_at.present?
  end

  # Inserts amount of product to this order in the context of given
  # parent item. Bundles are inserted as components right away.
  def insert(product, amount, group = nil, parent_item = nil)
    if product.bundle?
      insert_components(product, amount, group, parent_item)
    else
      insert_single(product, amount, group, parent_item, product.composite?)
    end
  end

  # Inserts the component products of given product to this order as
  # subitems of the given parent item.
  def insert_components(product, amount, group, parent_item)
    product.component_entries.each do |entry|
      insert(entry.component, amount * entry.quantity, group, parent_item)
    end
  end

  # Inserts a single product to this order, optionally with separate components.
  # Pricing is according to order source group if not specified.
  def insert_single(product, amount, group, parent_item, separate_components)
    pricing = Appraiser::Product.new(group || source)
    final_price = pricing.for_order(product)
    label = product.best_promoted_item(group).try(:description)
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).find_or_create_by(product: product, parent_item: parent_item)
    order_item.update!(
      amount: order_item.amount + amount,
      price: final_price.amount,
      tax_rate: final_price.tax_rate,
      price_includes_tax: final_price.tax_included,
      label: label || ''
    )
    if separate_components
      insert_components(product, amount, group, order_item)
    end
    order_item
  end

  # Copies the contents of this order to another order by inserting
  # the top level real items. Pricing is according to the source group
  # of the target order.
  def copy_items_to(another_order)
    transaction do
      order_items.top_level.real.each do |item|
        another_order.insert(item.product, item.amount, another_order.source)
      end
    end
  end

  # Forwards this order as another order by replacing its items with
  # items from this order, and copying some relevant info over.
  def forward_to(another_order)
    another_order.order_items.destroy_all
    copy_items_to(another_order)
    another_order.update(
      shipping_at: shipping_at,
      installation_at: installation_at,
      company_name: company_name,
      contact_person: contact_person,
      contact_email: contact_email,
      contact_phone: contact_phone,
      has_billing_address: has_billing_address,
      billing_address: billing_address,
      billing_postalcode: billing_postalcode,
      billing_city: billing_city,
      billing_country: billing_country,
      shipping_address: shipping_address,
      shipping_postalcode: shipping_postalcode,
      shipping_city: shipping_city,
      shipping_country: shipping_country,
      notes: notes
    )
  end

  # Recalculates things that may take some heavy lifting.
  # This should be called when the contents of the order have changed.
  def recalculate!
    apply_promotions!
    reload
  end

  # Finds the order types applicable to this order in the context
  # of given group. These are the outgoing order types for the group,
  # excluding those that are not suitable for one or more products
  # present in the order items.
  def available_order_types(group)
    group.outgoing_order_types.where(has_shipping: requires_shipping?)
  end

  # Finds the shipping methods available for this order based on which
  # methods are common to all ordered items. In case the order needs no
  # shipping, no shipping methods are returned.
  def available_shipping_methods
    return ShippingMethod.none unless has_shipping?
    ids = order_items.map { |item| item.product.available_shipping_methods.pluck(:id) }.inject(:&)
    store.shipping_methods.where(id: ids)
  end

  # Inserts an order item for the shipping cost using the shipping cost
  # product with the price queried from the given shipment.
  def apply_shipping_cost!(shipment, group)
    pricing = Appraiser::Product.new(group || source)
    cost = shipment.cost(pricing)
    unless cost.nil?
      order_items.create(
        product: shipment.shipping_cost_product,
        amount: 1,
        priority: 1e9,
        price: cost.amount,
        tax_rate: cost.tax_rate,
        price_includes_tax: cost.tax_included,
        label: ''
      )
    end
    order_items.reload
  end

  def clear_shipping_costs!
    order_items.where(product: store.shipping_cost_products).destroy_all
    order_items.reload
  end

  # Applies active promotions on the order, first removing all existing
  # adjustments from the order and its items.
  def apply_promotions!
    adjustments.destroy_all
    order_items.each { |order_item| order_item.adjustments.destroy_all }

    source.promotions.live.each do |promotion|
      promotion.apply!(self)
    end
  end

  # Order should complete when it reaches complete phase at checkout
  # but hasn't been completed yet.
  def should_complete?
    !complete? && checkout_phase == :complete
  end

  # Completing an order assigns it a number, archives it, sends
  # order receipt/acknowledge, and triggers an XML export job.
  def complete!
    assign_number!
    archive!
    email(has_payment? ? :receipt : :acknowledge, customer_string)
    export_xml
  end

  def assign_number!
    Order.with_advisory_lock('order_numbering') do
      current_max = store.orders.complete.maximum(:number).presence || store.order_sequence.presence || 0
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

  # Consumes stock for the order contents.
  def consume_stock!(inventory)
    transaction do
      order_items.each do |item|
        item.product.consume!(inventory, item.amount, self)
      end
    end
  end

  # Coalesces items in this order into a hash by product vendor.
  def items_by_vendor
    order_items.joins(product: :vendor).group_by { |item| item.product.vendor }
  end

  # VAT numbers are not mandatory, but expected to be present in orders
  # billed at a different country from the store home country.
  def vat_number_expected?
    return false unless has_payment?
    if has_billing_address?
      billing_country != store.country
    else
      shipping_country != store.country
    end
  end

  # Order lead time is based on its back ordered items.
  def lead_time_days(inventory)
    order_items.reject { |item|
      item.product.available?(inventory, item.amount)
    }.map { |item|
      item.product.lead_time_days
    }.compact.max || 0
  end

  def earliest_shipping_at(inventory)
    (completed_at || Date.current).to_date + lead_time_days(inventory).days
  end

  # An order is empty when it's empty of real products.
  def empty?
    products.real.empty?
  end

  # An order is quotable if it's a quote and there's a contact address.
  def quotable?
    is_quote? && contact_email.present?
  end

  # An order is checkoutable when all its real items can be
  # satisfied from given inventory.
  def checkoutable?(inventory)
    order_items.real.each do |item|
      return false unless item.satisfied?(inventory)
    end
    true
  end

  def paid?
    balance <= 0.to_money
  end

  def complete?
    completed_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  # Addresses this order to the given user if she has any addresses defined.
  def address_to(user)
    if user.shipping_address.present?
      self.shipping_address = user.shipping_address
      self.shipping_postalcode = user.shipping_postalcode
      self.shipping_city = user.shipping_city
      self.shipping_country = user.shipping_country
    end
    if user.billing_address.present?
      self.has_billing_address = true
      self.billing_address = user.billing_address
      self.billing_postalcode = user.billing_postalcode
      self.billing_city = user.billing_city
      self.billing_country = user.billing_country
    end
    ensure_valid_countries
  end

  def billing_address_components
    has_billing_address? ?
      [billing_address, billing_postalcode, billing_city] :
      [shipping_address, shipping_postalcode, shipping_city]
  end

  # Order having shipping is simply from the order type,
  # once it has been assigned. See below.
  def has_shipping?
    order_type.present? && order_type.has_shipping?
  end

  # Order requiring shipping is determined by its contents.
  # A single item that requires shipping will demand shipping
  # for the whole order.
  def requires_shipping?
    order_items.tangible.any?
  end

  def has_installation?
    order_type.present? && order_type.has_installation?
  end

  def has_payment?
    order_type.present? && order_type.has_payment?
  end

  def should_copy_billing_address?
    has_shipping? && has_payment? && !has_billing_address?
  end

  def billing_address_required?
    has_billing_address? || has_payment? && !has_shipping?
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
  def grand_total_for_export(inventory, items = order_items)
    items.map { |item|
      (item.subtotal_for_export(inventory) || 0.to_money) + item.adjustments_sans_tax
    }.sum + adjustments_sans_tax
  end

  def summary
    [company_name, contact_person, shipping_city].compact.reject(&:empty?).join(', ')
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

  def to_s
    number
  end

  # CSS class based on order status.
  def appearance
    return nil if concluded?
    approved? && 'warning text-warning' || 'danger text-danger'
  end

  # Icon name based on order status.
  def icon
    return nil if concluded?
    approved? && 'cog' || 'warning'
  end

  def as_json(options = {})
    super(methods: :checkout_phase)
  end

  def external_identifier
    [store.erp_number, number].join '/'
  end

  # Vis.js timeline representation of order events.
  def timeline_events
    events = []

    events << {
      group: id, type: 'range',
      className: (approved? ? 'primary' : 'danger'),
      content: I18n.l(completed_at.to_date),
      start: completed_at.to_date,
      end: approved_at.try(:to_date) || Time.current
    }
    events << {
      group: id, type: 'range',
      className: (concluded? ? 'success' : 'warning'),
      content: I18n.l(approved_at.to_date),
      start: approved_at.to_date,
      end: concluded_at.try(:to_date) || Time.current
    } if approved?

    events << {
      group: id, type: 'box',
      className: 'info',
      content: Order.human_attribute_name(:shipping_at),
      start: shipping_at
    } if shipping_at.present?

    events << {
      group: id, type: 'box',
      className: 'info',
      content: Order.human_attribute_name(:installation_at),
      start: installation_at
    } if installation_at.present?

    events
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
    def copy_billing_address
      self.billing_address = shipping_address
      self.billing_postalcode = shipping_postalcode
      self.billing_city = shipping_city
      self.billing_country = shipping_country
      true
    end

    def ensure_valid_countries
      self.shipping_country = store.country if shipping_country.nil?
      self.billing_country = store.country if billing_country.nil?
      true
    end

    # Perform XML export if specified by order type, and
    # store settings have a path defined.
    def export_xml
      if order_type.is_exported? && store.order_xml_path.present?
        OrderExportJob.perform_later(self, store.order_xml_path)
      end
    end

    # Approving an order sends the appropriate notifications.
    # If the order has already been paid, a processing notification
    # is sent. Otherwise an order confirmation is sent, and a copy
    # without pricing information is cc'd to the contact person.
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
end
