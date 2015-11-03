#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  monetize :value_cents, allow_nil: true

  #---
  belongs_to :inventory
  belongs_to :store
  belongs_to :product

  default_scope { order(:inventory_id) }
  scope :for_products, -> (products) {
    joins(:product).where('products.id IN (?)', products.pluck(:id))
  }

  #---
  # The adjustment of an inventory item is the sum of products
  # ordered in current orders that target the inventory this item
  # resides in.
  def adjustment
    product.order_items.joins(order: :order_type)
      .where.not(orders: {completed_at: nil})
      .where(orders: {approved_at: nil})
      .where(order_types: {inventory_id: inventory})
      .map { |item|
        item.order.order_type.adjustment_multiplier * item.amount
      }.sum
  end

  def total_value
    return nil if amount.nil? || value.nil?
    amount * value
  end

  # Inventory item HTML representation methods.
  def title; inventory.name; end
  def klass; inventory.purpose; end
end
