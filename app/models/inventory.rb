#encoding: utf-8

class Inventory < ActiveRecord::Base

  belongs_to :brand
  has_many :items

  # An inventory can have any number of order types that
  # reference the stock in this inventory.
  has_many :order_types

end
