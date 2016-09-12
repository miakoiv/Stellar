#encoding: utf-8

class Inventory < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  has_many :inventory_items, dependent: :destroy

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
