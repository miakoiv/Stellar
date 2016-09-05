#encoding: utf-8

class Inventory < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  # Inventories are for two purposes, manufacturing (products in the pipeline),
  # or shipping (products on hand).
  enum purpose: {manufacturing: 0, shipping: 1}

  #---
  belongs_to :store
  has_many :inventory_items, dependent: :destroy

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types, dependent: :destroy

  #---
  validates :name, presence: true

  #---
  # Returns the first inventory fulfilling given purpose.
  def self.by_purpose(purpose)
    find_by(purpose: purposes[purpose])
  end

  def self.purpose_options
    purposes.keys.map { |p| [Inventory.human_attribute_value(:purpose, p), p] }
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
