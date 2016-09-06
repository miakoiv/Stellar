#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  monetize :value_cents, allow_nil: true
  monetize :total_value_cents

  #---
  belongs_to :inventory
  belongs_to :store
  belongs_to :product

  default_scope { order(:inventory_id) }

  scope :manufacturing, -> { joins(:inventory).merge(Inventory.manufacturing) }
  scope :shipping, -> { joins(:inventory).merge(Inventory.shipping) }

  scope :for_products, -> (products) {
    joins(:product).where('products.id IN (?)', products.pluck(:id))
  }

  #---
  # The adjustment of an inventory item is the sum of products
  # ordered in current orders that target the inventory this item
  # resides in.
  def adjustment
    product.order_items.joins(order: :order_type)
      .merge(Order.current)
      .where(order_types: {inventory_id: inventory})
      .map { |item|
        item.order.order_type.adjustment_multiplier * item.amount
      }.sum
  end

  def total_value_cents
    return 0 if amount.nil? || value_cents.nil? || amount < 0
    amount * value_cents
  end

  def title
    inventory.name
  end

  def appearance
    inventory.purpose
  end
end
