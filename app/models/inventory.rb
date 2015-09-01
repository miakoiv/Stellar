#encoding: utf-8

class Inventory < ActiveRecord::Base

  # An inventory optionally belongs to a store, when
  # the store uses specific inventories.
  belongs_to :store

  has_many :inventory_items

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types

  # Inventories are for two purposes, manufacturing (products in the pipeline),
  # or shipping (products on hand).
  enum purpose: {manufacturing: 0, shipping: 1}


  default_scope { order(:purpose) }

  # Global scope for inventories that are not store specific.
  scope :global, -> { where(store_id: nil) }

  #---
  # Returns the first inventory fulfilling given purpose.
  def self.by_purpose(purpose)
    find_by(purpose: purposes[purpose])
  end

  #---
  # Inventory lookup by product code.
  def lookup(code)
    inventory_items.find_by(code: code)
  end
end
