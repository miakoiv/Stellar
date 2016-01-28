#encoding: utf-8

class OrderType < ActiveRecord::Base

  has_many :orders

  # Orders of this type refer to stock in this particular inventory.
  belongs_to :inventory

  #---
  def tab_name
    name
  end

  def to_s
    name
  end
end
