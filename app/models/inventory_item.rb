#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  belongs_to :inventory

  # Inventory items don't reference a product directly,
  # instead there is a `code` attribute that may refer to
  # multiple products under different brands simultaneously.

end
