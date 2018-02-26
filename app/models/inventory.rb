#encoding: utf-8

class Inventory < ActiveRecord::Base

  resourcify
  include Authority::Abilities
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
  def stock
    items = inventory_items
    [items, items.map(&:value).sum]
  end

  # Restocks the inventory from given inventory item from another inventory.
  def restock!(another_item, amount, recorded_at, source = nil)
    item = inventory_items.find_or_initialize_by(
      product: another_item.product,
      code: another_item.code,
      expires_at: another_item.expires_at
    )
    item.inventory_entries.build(
      recorded_at: recorded_at,
      source: source,
      on_hand: amount,
      reserved: 0,
      pending: 0,
      value: another_item.value
    )
    item.save!
  end

  def to_s
    name
  end
end
