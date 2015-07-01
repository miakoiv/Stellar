#encoding: utf-8

class Inventory < ActiveRecord::Base

  belongs_to :brand
  has_many :inventory_items

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types

  # Finds the first inventory by name, either Manufacturing or Shipping.
  scope :which, -> (name) { where(name: name).first }

end
