#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  belongs_to :inventory

  # Inventory items don't reference a product directly,
  # instead there is a `code` attribute that may refer to
  # multiple products under different stores simultaneously.

  default_scope { order(:inventory_id) }


  # Returns a hash of stock numbers for a product code,
  # see Product#stock_lookup for the format.
  def self.stock(code)
    stock = {}.tap do |stock|
      where(code: code).each do |item|
        stock[item.inventory.purpose] = {
          current: item.amount || 0,
          adjustment: 0
        }
      end
    end
  end
end
