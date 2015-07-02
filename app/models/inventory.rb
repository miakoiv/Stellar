#encoding: utf-8

class Inventory < ActiveRecord::Base

  has_many :inventory_items

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types

  # Inventories are for two purposes, manufacturing (products in the pipeline),
  # or shipping (products on hand).
  enum purpose: {manufacturing: 0, shipping: 1}

  default_scope { order(:purpose) }

  # Finds the first inventory by purpose.
  def self.for(purpose)
    where(purpose: purposes[purpose]).first
  end
end
