class Order < ApplicationRecord

  include Addressed

  belongs_to :billing_group, class_name: 'Group'
  belongs_to :shipping_group, class_name: 'Group'

  has_many :payments, dependent: :destroy, inverse_of: :order
  has_many :shipments, dependent: :destroy, inverse_of: :order

  before_validation :copy_shipping_address, if: :should_copy_shipping_address?
  before_save :check_separate_shipping_address

  validates :billing_address, presence: true, if: :has_payment?
  validates :shipping_address, presence: true, if: :shipping_address_required?

  #---
  def last_completed_shipment
    shipments.complete.first
  end

  def should_copy_shipping_address?
    has_shipping? && (shipping_address.nil? || !separate_shipping_address?)
  end

  def shipping_address_required?
    has_shipping? && (!has_payment? || separate_shipping_address?)
  end

  # Order having shipping is simply from the order type,
  # once it has been assigned. See #requires_shipping?
  def has_shipping?
    return false unless customer_required?
    order_type.has_shipping?
  end
  scope :has_shipping, -> { joins(:order_type).merge(OrderType.has_shipping) }

  # Shipments are tracked via transfers, unless the store has them disabled.
  def track_shipments?
    !store.disable_shipment_transfers?
  end

  def has_pending_shipment?
    shipments.pending.any?
  end

  def fully_shipped?
    return true if !track_shipments?
    order_items.select(&:pending?).none?
  end

  def earliest_shipping_at
    (completed_at || Date.current).to_date + lead_time_days.days
  end

  # Finds the shipping methods available for this order based on which
  # methods are common to all ordered items. In case the order needs no
  # shipping, no shipping methods are returned.
  def available_shipping_methods
    return ShippingMethod.none unless has_shipping?
    ids = order_items.map { |item| item.product.available_shipping_methods.pluck(:id) }.inject(:&)
    store.shipping_methods.where(id: ids)
  end

  def has_payment?
    order_type.present? && order_type.has_payment?
  end

  def billing_address_components
    [billing_address.address1, billing_address.postalcode, billing_address.city]
  end

  # VAT numbers are not mandatory, but expected to be present in orders
  # billed at a different country from the store home country.
  def vat_number_expected?
    return false unless has_payment?
    billing_address.country != store.country
  end

  # Addresses the order to its customer unless guest mode is specified.
  # FIXME: this should do something
  def address_to_customer(guest = false)
  end

  # Inserts an order item for the shipping cost using the shipping cost
  # product with the price queried from the given shipment.
  def apply_shipping_cost!(shipment)
    cost = shipment.cost(product_pricing)
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

  def update_shipped!
    transaction do
      order_items.each do |order_item|
        order_item.update_shipped!
      end
    end
  end

  # Collects order items that are awaiting shipping.
  def items_waiting
    order_items.lot_codes_first.select { |item| item.waiting? }
  end

  def clear_shipping_costs!
    order_items.where(product: store.shipping_cost_products).destroy_all
    order_items.reload
  end

  private
    def copy_shipping_address
      self.shipping_address = billing_address.dup
    end

    def check_separate_shipping_address
      if billing_address && shipping_address && billing_address == shipping_address
        self.separate_shipping_address = false
      end
    end
end
