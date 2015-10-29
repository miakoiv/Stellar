#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Adjustable

  #---
  belongs_to :store
  belongs_to :user
  belongs_to :order_type
  delegate :is_rfq?, :is_quote?, to: :order_type

  has_many :order_items, dependent: :destroy, inverse_of: :order

  # Current orders are completed, not yet approved orders.
  scope :current, -> { where.not(ordered_at: nil).where(approved_at: nil) }

  # Completed orders, approved or not.
  scope :completed, -> { where.not(ordered_at: nil) }

  # Unordered orders is the scope for shopping carts.
  scope :unordered, -> { where(ordered_at: nil) }

  # Approved orders.
  scope :approved, -> { where.not(approved_at: nil) }

  # Orders of specified store.
  scope :by_store, -> (store) { where(store: store) }

  #---
  validates :customer_name, presence: true, on: :update
  validates :customer_email, presence: true, on: :update
  validates :shipping_address, :shipping_postalcode, :shipping_city,
    presence: true, on: :update,
    if: :has_shipping?

  validates :billing_address, :billing_postalcode, :billing_city,
    presence: true, on: :update,
    if: -> (order) { order.has_shipping? && order.has_billing_address? }

  #---
  before_save :copy_billing_address, unless: :has_billing_address?

  #---
  # Only show prices for RFQs.
  def reveal_prices?
    is_rfq?
  end

  # Only show product components for non-RFQs.
  def reveal_components?
    !is_rfq?
  end

  def approval
    !!approved_at.present?
  end
  alias approved? approval

  # Setting approval status also archives the order and its order items.
  def approval=(status)
    case status
    when '1'
      archive!
      update(approved_at: Time.current)
    when '0'
      update(approved_at: nil)
    else
      raise "Unknown approval status #{status}"
    end
  end

  def insert!(product, amount)
    order_item = order_items.create_with(amount: 0).find_or_create_by(product: product)
    order_item.amount += amount
    order_item.price = product.sales_price
    order_item.save!
    apply_shipping_cost!
    apply_promotions!
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

  # Collects aggregated component quantities of all products in the order.
  # Returns a hash of quantities keyed by product object.
  def aggregated_components
    aggregated = {}.tap do |aggregated|
      order_items.each do |item|
        item.product.relationships.each do |relationship|
          aggregated[relationship.component] ||= 0
          aggregated[relationship.component] += item.amount * relationship.quantity
        end
      end
    end
  end

  # An order is empty when it's empty of non-virtual items.
  def empty?
    order_items.real.empty?
  end

  def has_shipping?
    order_type.present? && order_type.has_shipping?
  end

  def has_payment?
    order_type.present? && order_type.has_payment?
  end

  def adjustment_total
    adjustments.map(&:amount).sum
  end

  # Total sum without virtual items (like shipping and handling).
  def total
    order_items.real.map { |item| item.subtotal + item.adjustment_total }.sum + adjustment_total
  end

  # Grand total, including virtual items.
  def grand_total
    order_items.map { |item| item.subtotal + item.adjustment_total }.sum + adjustment_total
  end

  def padded_id
    '1%07d' % id
  end

  def to_s
    new_record? ? '' : padded_id
  end

  private
    def copy_billing_address
      self.billing_address = shipping_address
      self.billing_postalcode = shipping_postalcode
      self.billing_city = shipping_city
    end

    def calculated_shipping_cost
      default_price = store.shipping_cost_product.sales_price
      return default_price if store.free_shipping_at.nil? || total < store.free_shipping_at.to_money
      return 0.to_money
    end

    def archive!
      transaction do
        update(
          store_name: store.name,
          store_contact_person_name: store.contact_person.name,
          store_contact_person_email: store.contact_person.email,
          user_name: user.try(:name),
          user_email: user.try(:email),
          order_type_name: order_type.name
        )
        order_items.each do |item|
          item.archive!
        end
      end
    end
end
