#encoding: utf-8

class Inventory < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Reorderable

  #---
  belongs_to :store
  has_many :inventory_items, dependent: :destroy

  # Orders may specify a target inventory.
  has_many :orders

  default_scope { sorted }

  #---
  validates :name, presence: true

  #---
  def stock
    items = inventory_items
    [items, items.map(&:value).sum]
  end

  def to_s
    name
  end
end
