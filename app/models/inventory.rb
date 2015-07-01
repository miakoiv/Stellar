#encoding: utf-8

class Inventory < ActiveRecord::Base

  has_many :inventory_items

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types

  # Finds the first inventory by name, either Manufacturing or Shipping.
  scope :which, -> (name) { where(name: name).first }

  # Looks up the inventory item by product code and inventory name.
  def self.lookup(code, inventory)
    which(inventory).inventory_items.where(code: code).first
  end

end
