#encoding: utf-8

class Order < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  belongs_to :user
  belongs_to :order_type
  has_many :order_items, dependent: :destroy

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
  validates :shipping_address, :shipping_postalcode, :shipping_city,
    presence: true, on: :update,
    if: :has_shipping?

  validates :billing_address, :billing_postalcode, :billing_city,
    presence: true, on: :update,
    if: -> (order) { order.has_shipping? && order.has_billing_address? }

  #---
  before_save :copy_billing_address, unless: :has_billing_address?
  after_touch :apply_shipping_cost

  #---
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
    order_item.save
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

  def has_shipping?
    order_type.present? && order_type.has_shipping?
  end

  def has_payment?
    order_type.present? && order_type.has_payment?
  end

  def grand_total
    order_items.map { |item| item.amount * (item.price || 0) }.sum
  end

  def grand_total_without_shipping
    order_items
      .reject { |item| item.is_shipping_cost? }
      .map { |item| item.amount * (item.price || 0) }
      .sum
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

    def apply_shipping_cost
      return if store.shipping_cost_product.nil?
      order_items.create_with(amount: 1).find_or_create_by(product: store.shipping_cost_product).update(price: calculated_shipping_cost)
    end

    def calculated_shipping_cost
      default_price = store.shipping_cost_product.sales_price
      return default_price if store.free_shipping_at.nil? || grand_total_without_shipping < store.free_shipping_at
      return 0.00
    end

    def archive!
      transaction do
        update(
          store_name: store.name,
          store_contact_person_name: store.contact_person.name,
          store_contact_person_email: store.contact_person.email,
          user_name: user.name,
          user_email: user.email,
          order_type_name: order_type.name
        )
        order_items.each do |item|
          item.archive!
        end
      end
    end
end
