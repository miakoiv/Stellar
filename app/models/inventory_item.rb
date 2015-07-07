#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  belongs_to :inventory

  # Inventory items don't reference a product directly,
  # instead there is a `code` attribute that may refer to
  # multiple products under different stores simultaneously.

  default_scope { order(:inventory_id) }

  # Performs an inventory lookup on product code.
  # Returns a hash of items like {'manufacturing' => 100, 'shipping' => 50}
  def self.lookup(code)
    where(code: code).map { |i| [i.inventory.purpose, i.amount || 0] }.to_h
  end
end
