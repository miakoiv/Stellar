#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable
  monetize :balance_cents, disable_validation: true
  monetize :grand_total_sans_tax_cents, :tax_total_cents, :grand_total_with_tax_cents, disable_validation: true
  monetize :adjustments_sans_tax_cents, :adjustments_with_tax_cents, disable_validation: true

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

  # Current orders are completed, not yet approved orders.
  scope :current, -> { where.not(completed_at: nil).where(approved_at: nil) }

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

  # Orders that are not concluded or have been concluded not longer than
  # one week ago are topical. This is used for timeline data.
  scope :topical, -> { where('concluded_at IS NULL OR concluded_at > ?', 2.weeks.ago) }

  scope :has_shipping, -> { joins(:order_type).merge(OrderType.has_shipping) }

  # Incoming and outgoing orders for given user, based on order type.
  scope :incoming_for, -> (user) { joins(:order_type).merge(OrderType.incoming_for(user)) }
  scope :outgoing_for, -> (user) { joins(:order_type).merge(OrderType.outgoing_for(user)) }

  # The corresponding methods for above scopes are found in OrderType.
  delegate :incoming_for?, to: :order_type
  delegate :outgoing_for?, to: :order_type

  #---
  validates :customer_name, presence: true, on: :update
  validates :customer_email, presence: true, on: :update
  validates :customer_phone, presence: true, on: :update

  validates :shipping_address, :shipping_postalcode, :shipping_city,
    presence: true, on: :update,
    if: :has_shipping?

  validates :billing_address, :billing_postalcode, :billing_city,
    presence: true, on: :update,
    if: -> (order) { order.has_shipping? && order.has_billing_address? }

  #---
  # This attribute allows adding products en masse
  # through a string of comma-separated ids.
  attr_accessor :product_ids_string

  #---
  before_save :copy_billing_address, unless: :has_billing_address?

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

  # Allow adding and editing order items on quotations only.
  def editable_items?
    is_quote?
  end

  # Confirmation mail is not sent for quotations.
  def send_confirmation?
    !is_quote?
  end

  # Notify users with order_notify role in the destination group.
  def notified_users
    store.users.where(group: order_type.destination_group).with_role(:order_notify)
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

  # Inserts amount of product to this order in the context of given pricing
  # group and parent item. Bundles are inserted as components right away.
  # Pricing is initially for retail. Depending on the user's group,
  # different pricing may be applied at checkout by Order#reappraise!
  def insert(product, amount, pricing = nil, parent_item = nil)
    if product.bundle?
      insert_components(product, amount, pricing, parent_item)
    else
      insert_single(product, amount, pricing, parent_item, product.composite?)
    end
  end

  # Inserts a single product to this order, optionally with separate components
  # that are deducted from the price of this product.
  def insert_single(product, amount, pricing, parent_item, separate_components)
    price_cents = product.price_cents(pricing)
    if separate_components
      price_cents -= product.component_total_price_cents(pricing)
    end
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).find_or_create_by(product: product, parent_item: parent_item)
    order_item.update!(
      amount: order_item.amount + amount,
      price_cents: price_cents,
      tax_rate: product.tax_category.rate,
      price_includes_tax: product.tax_category.included_in_retail
    )
    if separate_components
      insert_components(product, amount, pricing, order_item)
    end
    order_item
  end

  # Inserts the component products of given product to this order as
  # subitems of the given parent item.
  def insert_components(product, amount, pricing, parent_item)
    product.component_entries.each do |entry|
      insert(entry.component, amount * entry.quantity, pricing, parent_item)
    end
  end

  # Inserts the contents of given order item to this order.
  # This is useful for copying order items from another order.
  def insert_order_item(item, parent_item = nil)
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).find_or_create_by(product: item.product, parent_item: parent_item)
    order_item.amount += item.amount
    order_item.price_cents = item.price_cents
    order_item.save!
    item.subitems.each do |subitem|
      insert_order_item(subitem, order_item)
    end
  end

  # Copies the top level order items on this order to another order.
  # Any subitems are recursively copied by #insert_order_item.
  def copy_items_to(another_order)
    order_items.top_level.real.each do |order_item|
      another_order.insert_order_item(order_item)
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

  # Reappraising the order modifies the order item prices according to
  # given pricing group. This is called whenever the order type changes.
  def reappraise!(pricing_group)
    user_specific = order_type.present? && !is_quote?
    order_items.each do |order_item|
      next if order_item.product.internal?
      if user_specific
        order_item.update(
          price_cents: user.price_for_cents(order_item.product, pricing_group),
          price_includes_tax: user.price_includes_tax?(order_item.product),
          label: user.label_for(order_item.product)
        )
      else
        order_item.update(
          price_cents: order_item.product.price_cents(pricing_group),
          price_includes_tax: order_item.product.tax_category.included_in_retail?,
          label: nil
        )
      end
    end
  end

  # Recalculate things that may take some heavy lifting. This should be called
  # when the contents of the order have changed.
  def recalculate!
    apply_promotions!
    reload
  end

  # Applies the shipping cost incurred by given shipping method, if any.
  # Existing shipping costs are removed first.
  def apply_shipping_cost!(shipping_method, pricing = nil)
    clear_shipping_costs!
    product = shipping_method.shipping_cost_product
    return if product.nil?
    threshold = shipping_method.free_shipping_from
    total = includes_tax? ? grand_total_with_tax : grand_total_sans_tax
    if threshold.nil? || total < threshold
      item = insert(product, 1, pricing)
      item.update(priority: 1e9)
    end
    order_items.reload
  end

  def clear_shipping_costs!
    order_items.where(product: store.shipping_cost_products).destroy_all
  end

  # Applies active promotions on the order, first removing all existing
  # adjustments from the order and its items.
  def apply_promotions!
    adjustments.destroy_all
    order_items.each { |order_item| order_item.adjustments.destroy_all }

    store.promotions.active.each do |promotion|
      promotion.apply!(self)
    end
  end

  # Order should complete when it reaches complete phase at checkout
  # but hasn't been completed yet.
  def should_complete?
    !complete? && checkout_phase == :complete
  end

  # Completing an order assigns it a number, archives it, sends
  # order confirmation(s), and triggers an XML export job.
  def complete!
    assign_number!
    archive!
    send_confirmations
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

  # Consumes stock for the order contents if it includes shipping.
  def consume_stock!
    return true unless has_shipping?
    transaction do
      order_items.each do |item|
        item.product.consume!(item.amount, self)
      end
    end
  end

  # Sends an order confirmation/receipt to the customer, and additional
  # notifications to vendors if the order contains any of their products.
  # A separate order notification is sent to the contact person, if applicable.
  def send_confirmations
    return unless send_confirmation?
    method = store.b2b_sales? ? :order_confirmation : :order_receipt
    OrderMailer.send(method, self).deliver_later
    OrderMailer.order_notification(self).deliver_later if has_contact_info?
    items_by_vendor.each do |vendor, items|
      OrderMailer.vendor_notification(self, vendor, items).deliver_later
    end
  end

  # Coalesces items in this order into a hash by product vendor.
  def items_by_vendor
    order_items.joins(product: :vendor).group_by { |item| item.product.vendor }
  end

  # VAT numbers are not mandatory, but expected to be present in orders
  # billed at a different country from the store home country.
  def vat_number_expected?
    return false unless has_shipping?
    if has_billing_address?
      billing_country != store.country
    else
      shipping_country != store.country
    end
  end

  # Order lead time is the maximum of its items.
  def lead_time
    order_items.map(&:lead_time).max
  end

  def earliest_shipping_at
     (completed_at || Date.current).to_date + lead_time.days
  end

  # An order is empty when it's empty of real products.
  def empty?
    products.real.empty?
  end

  # An order is quotable if it's a quote and there's a contact address.
  def quotable?
    is_quote? && contact_email.present?
  end

  # An order is checkoutable when all its real items are available.
  def checkoutable?
    products.real.each do |product|
      return false unless product.available?
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
  # The country on both addresses is set to store default if none is set yet.
  def address_to(user)
    if user.shipping_address.present?
      self.shipping_address ||= user.shipping_address
      self.shipping_postalcode ||= user.shipping_postalcode
      self.shipping_city ||= user.shipping_city
      self.shipping_country ||= user.shipping_country
    end
    if user.billing_address.present?
      self.has_billing_address = true
      self.billing_address ||= user.billing_address
      self.billing_postalcode ||= user.billing_postalcode
      self.billing_city ||= user.billing_city
      self.billing_country ||= user.billing_country
    end
    self.shipping_country ||= store.country
    self.billing_country ||= store.country
  end

  def billing_address_components
    has_billing_address? ?
      [billing_address, billing_postalcode, billing_city] :
      [shipping_address, shipping_postalcode, shipping_city]
  end

  # Do prices shown include tax?
  def includes_tax?
    !store.b2b_sales?
  end

  def has_shipping?
    order_type.present? && order_type.has_shipping?
  end

  def has_installation?
    order_type.present? && order_type.has_installation?
  end

  def has_payment?
    order_type.present? && order_type.has_payment?
  end

  def balance_cents
    grand_total_with_tax_cents - payments.sum(:amount_cents)
  end

  # Grand total for the given items (or whole order), without tax.
  def grand_total_sans_tax_cents(items = order_items)
    items.map { |item|
      (item.subtotal_sans_tax_cents || 0) + item.adjustments_sans_tax_cents
    }.sum + adjustments_sans_tax_cents
  end

  # Same as above, with tax.
  def grand_total_with_tax_cents(items = order_items)
    items.map { |item|
      (item.subtotal_with_tax_cents || 0) + item.adjustments_with_tax_cents
    }.sum + adjustments_with_tax_cents
  end

  # Total tax for the given items.
  def tax_total_cents(items = order_items)
    items.map { |item| item.tax_subtotal_cents || 0 }.sum
  end

  def adjustments_sans_tax_cents
    adjustments.map { |a| a.amount_sans_tax_cents || 0 }.sum
  end

  def adjustments_with_tax_cents
    adjustments.map { |a| amount_with_tax_cents || 0 }.sum
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

  # Letterhead for this order based on its destination.
  def letterhead
    group = User.groups.key(order_type.destination_group)
    page_id = store.send("#{group}_template_id")
    return '' unless page_id.present?
    store.pages.find(page_id).content
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

  private
    def copy_billing_address
      self.billing_address = shipping_address
      self.billing_postalcode = shipping_postalcode
      self.billing_city = shipping_city
    end

    # Perform XML export if specified by order type, and
    # store settings have a path defined.
    def export_xml
      if order_type.is_exported? && store.order_xml_path.present?
        OrderExportJob.perform_later(self, store.order_xml_path)
      end
    end

    # Approving an order consumes stock for the ordered items.
    def approve!
      reload # to clear changes and prevent a callback loop
      consume_stock!
      true
    end

    # Concluding an order creates asset entries for it.
    def conclude!
      reload # to clear changes and prevent a callback loop
      CustomerAsset.create_from(self)
      true
    end
end
