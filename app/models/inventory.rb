#encoding: utf-8

class Inventory < ActiveRecord::Base

  # Inventories are for two purposes, manufacturing (products in the pipeline),
  # or shipping (products on hand).
  enum purpose: {manufacturing: 0, shipping: 1}

  #---
  has_and_belongs_to_many :stores
  has_many :inventory_items

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types

  #---
  # Returns the first inventory fulfilling given purpose.
  def self.by_purpose(purpose)
    find_by(purpose: purposes[purpose])
  end

  #---
  def stock
    items = inventory_items
    [items, items.map(&:value).sum]
  end

  def to_s
    name
  end
end
