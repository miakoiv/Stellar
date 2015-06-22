#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  belongs_to :inventory
  belongs_to :product
end
