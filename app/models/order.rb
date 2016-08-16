#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable
  monetize :adjustment_total_cents
  monetize :balance_cents
  monetize :total_cents
  monetize :grand_total_cents

  #---
  belongs_to :store
  belongs_to :user
  belongs_to :order_type
  delegate :is_rfq?, :is_quote?, to: :order_type

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :products, through: :order_items
  has_many :payments, dependent: :destroy, inverse_of: :order

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
  validates_associated :order_items, on: :update
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

  def contact_string
    contact_person.present? && contact_email.present? ? "#{contact_person} <#{contact_email}>" : nil
  end

  def approval
    !!approved_at.present?
  end
  alias approved? approval

  def approval=(status)
    if ['1', 1, true].include?(status)
      update(approved_at: Time.current) unless approved?
    else
      update(approved_at: nil)
    end
  end

  def conclusion
    !!concluded_at.present?
  end
  alias concluded? conclusion

  # Concluding an order archives the order and its order items.
  # For each order item, an asset entry is created.
  def conclusion=(status)
    if ['1', 1, true].include?(status)
      if !concluded?
        create_asset_entries!
        archive!
        update(concluded_at: Time.current)
      end
    else
      update(concluded_at: nil)
    end
  end

  # Inserts amount of product to this order in the context of given pricing
  # group. If the product is a compound, its immediate components are inserted
  # instead. Pricing is initially for retail. Depending on the user's group,
  # different pricing may be applied at checkout by Order#reappraise!
  def insert(product, amount, pricing_group = nil)
    if product.compound?
      product.component_entries.each do |entry|
        insert(entry.component, entry.quantity, pricing_group)
      end
    else
      order_item = order_items.create_with(
        amount: 0,
        priority: order_items_count
      ).find_or_create_by(product: product)
      order_item.amount += amount
      order_item.price = product.price(pricing_group)
      order_item.save!
    end
  end

  # Inserts the contents of given order item to this order.
  # This is useful for copying order items from another order.
  def insert_order_item(item)
    order_item = order_items.create_with(
      amount: 0,
      priority: order_items_count
    ).find_or_create_by(product: item.product)
    order_item.amount += item.amount
    order_item.price = item.price
    order_item.save!
  end

  # Copies order items on this order to another order. Any order items
  # referring to a product that's not available are returned as failed items.
  def copy_items_to(another_order)
    failed_items = []
    order_items.includes(:product).each do |order_item|
      product = order_item.product
      next if product.virtual?
      if product.live?
        another_order.insert_order_item(order_item)
      else
        failed_items << product
      end
    end
    failed_items
  end

  # Forwards this order as another order by replacing its items with
  # items from this order, and copying some relevant info over.
  # Returns items that failed just like #copy_items_to above.
  def forward_to(another_order)
    another_order.order_items.destroy_all
    failed_items = copy_items_to(another_order)
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
    failed_items
  end

  # Reappraising the order modifies the order item prices according to
  # given pricing group. When called at checkout, the order type is known
  # and may specify user specific pricing to be applied.
  def reappraise!(pricing_group)
    trade_prices = order_type.present? && !is_quote?
    order_items(includes: :product).each do |order_item|
      if trade_prices
        order_item.update(
          price: user.price_for(order_item.product, pricing_group),
          label: user.label_for(order_item.product)
        )
      else
        order_item.update(
          price: order_item.product.price(pricing_group),
          label: nil
        )
      end
    end
  end

  # Recalculate things that may take some heavy lifting. This should be called
  # when the contents of the order have changed.
  def recalculate!
    apply_shipping_cost!
    apply_promotions!
    reload
  end

  # Applies a shipping cost for the current contents of the order.
  # The shipping cost is an order item referencing a virtual product
  # defined by the store.
  def apply_shipping_cost!
    return if store.shipping_cost_product.nil?
    item = order_items.create_with(
      amount: 1, priority: 1e9
    ).find_or_create_by(
      product: store.shipping_cost_product
    )
    item.update(price: calculated_shipping_cost)

    # Reloading order items that may have gone out of sync.
    order_items(reload)
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

  # Completing an order sets the completion timestamp and
  # assigns a number from the sequence in the store.
  def complete!
    Order.with_advisory_lock('order_numbering') do
      current_max = store.orders.complete.maximum(:number) || store.order_sequence
      update(number: current_max.succ, completed_at: Time.current)
    end
  end

  # Collects aggregated component quantities of all products in the order.
  # Returns a hash of quantities keyed by product object.
  def aggregated_components
    aggregated = {}.tap do |aggregated|
      order_items.each do |item|
        item.product.component_entries.each do |entry|
          aggregated[entry.component] ||= 0
          aggregated[entry.component] += item.amount * entry.quantity
        end
      end
    end
  end

  # Returns the lead time for this order based on the contained products.
  def lead_time
    products.maximum(:lead_time)
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
    return true
  end

  # An order is considered paid if its order type requires no payment,
  # or its balance reaches zero.
  def paid?
    !has_payment? || balance_cents <= 0
  end
  alias_method :paid, :paid?

  def complete?
    completed_at.present?
  end
  alias_method :complete, :complete?

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
  end

  def billing_address_components
    has_billing_address? ?
      [billing_address, billing_postalcode, billing_city] :
      [shipping_address, shipping_postalcode, shipping_city]
  end

  def has_shipping?
    order_type.present? && order_type.has_shipping?
  end

  def has_payment?
    order_type.present? && order_type.has_payment?
  end

  def payment_gateway
    "PaymentGateway::#{order_type.payment_gateway}".constantize
  end

  def adjustment_total_cents
    adjustments.sum(:amount_cents)
  end

  def balance_cents
    grand_total_cents - payments.sum(:amount_cents)
  end

  # Total sum counting only real items (excluding shipping and handling).
  def total_cents
    order_items.real.map { |item| item.subtotal_cents + item.adjustment_total_cents }.sum + adjustment_total_cents
  end

  # Grand total, including virtual items.
  def grand_total_cents
    order_items.map { |item| item.subtotal_cents + item.adjustment_total_cents }.sum + adjustment_total_cents
  end

  def summary
    [company_name, contact_person, shipping_city].compact.reject(&:empty?).join(', ')
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
    super(methods: [:paid, :complete])
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

    def calculated_shipping_cost
      default_price = store.shipping_cost_product.retail_price
      return default_price if store.free_shipping_at.nil? || total < store.free_shipping_at.to_money
      return 0.to_money
    end

    def create_asset_entries!
      CustomerAsset.create_from(self)
    end

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
end
