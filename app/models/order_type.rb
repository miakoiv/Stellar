#encoding: utf-8

class OrderType < ActiveRecord::Base

  has_many :orders

  # Orders of this type refer to stock in this particular inventory.
  belongs_to :inventory

  scope :has_shipping, -> { where(has_shipping: true) }

  #---
  def to_s
    name
  end
end
