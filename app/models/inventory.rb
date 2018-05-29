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
    inventory_items.for(product).find_by(code: code)
  end

  def stock
    items = inventory_items
    [items, items.map(&:value).sum]
  end

  # Restocks the inventory with given transfer item that specifies
  # the product, a lot code, expiration, and amount. New inventory
  # items may be created if not seen before.
  def restock!(transfer_item, timestamp, source = nil)
    item = inventory_items.find_or_initialize_by(
      product: transfer_item.product,
      code: transfer_item.lot_code
    ) { |item| item.expires_at = transfer_item.expires_at }
    item.inventory_entries.build(
      recorded_at: timestamp,
      source: source,
      on_hand: transfer_item.amount,
      reserved: 0,
      pending: 0,
      value: item.value || transfer_item.product.trade_price || 0
    )
    item.save!
  end

  # Destocks the inventory from given transfer item that specifies
  # a product, a lot code, and an amount. The inventory item must exist.
  def destock!(transfer_item, timestamp, source = nil)
    item = inventory_items.find_by(
      product: transfer_item.product,
      code: transfer_item.lot_code
    )
    item.inventory_entries.build(
      recorded_at: timestamp,
      source: source,
      on_hand: -transfer_item.amount,
      reserved: 0,
      pending: 0,
      value: item.value
    )
    item.save!
  end

  def to_s
    name
  end
end
