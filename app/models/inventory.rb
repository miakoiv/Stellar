#encoding: utf-8

class Inventory < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable
  include Reorderable

  #---
  belongs_to :store
  has_many :inventory_items, dependent: :destroy

  # Orders may specify a target inventory.
  has_many :orders

  default_scope { sorted }

  #---
  validates :name, presence: true

  #---
  # Finds an item by product and lot code.
  def item_by_product_and_code(product, code)
    items_by_product(product).find_by(code: code)
  end

  # Finds items by product.
  def items_by_product(product)
    inventory_items.for(product)
  end

  def stock
    items = inventory_items
    [items, items.map(&:value).sum]
  end

  # Restocks the inventory with given item that specifies a product,
  # lot code, expiration, and amount. New inventory items may be
  # created if not seen before. The affected inventory item is returned.
  def restock!(item, timestamp, source = nil)
    inventory_item = inventory_items.create_with(
      expires_at: item.expires_at
    ).find_or_create_by!(
      product: item.product,
      code: item.lot_code
    )
    inventory_item.inventory_entries.create!(
      recorded_at: timestamp,
      source: source,
      on_hand: item.amount,
      reserved: 0,
      pending: 0,
      value: inventory_item.value || item.product.trade_price || 0
    )
    inventory_item
  end

  # Destocks the inventory using given item that specifies
  # a product, lot code, and amount. The inventory item must exist,
  # and will be returned.
  def destock!(item, timestamp, source = nil)
    inventory_item = inventory_items.find_by(
      product: item.product,
      code: item.lot_code
    )
    inventory_item.inventory_entries.create!(
      recorded_at: timestamp,
      source: source,
      on_hand: -item.amount,
      reserved: 0,
      pending: 0,
      value: inventory_item.value
    )
    inventory_item
  end

  def to_s
    name
  end
end
