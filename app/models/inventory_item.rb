#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  belongs_to :inventory

  # Inventory items don't reference a product directly,
  # instead there is a `code` attribute that may refer to
  # multiple products under different stores simultaneously.

  default_scope { order(:inventory_id) }

end
