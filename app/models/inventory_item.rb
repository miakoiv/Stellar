#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  monetize :value_cents, allow_nil: true
  monetize :total_value_cents

  #---
  belongs_to :inventory
  belongs_to :product

  default_scope { order(:inventory_id) }

  #---
  def total_value_cents
    return 0 if on_hand.nil? || value_cents.nil? || on_hand < 0
    on_hand * value_cents
  end

  def title
    inventory.name
  end

  def appearance
    on_hand > 0 ? 'success' : 'warning'
  end
end
