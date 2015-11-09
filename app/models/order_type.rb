#encoding: utf-8

class OrderType < ActiveRecord::Base

  has_many :orders

  # Orders of this type refer to stock in this particular inventory.
  belongs_to :inventory

  # Source and destination roles define who can initiate an order of this type
  # and who will process (approve) it as an administrator.
  belongs_to :source_role, class_name: 'Role', inverse_of: :available_order_types
  belongs_to :destination_role, class_name: 'Role', inverse_of: :managed_order_types

  #---
  def tab_name
    name
  end

  def to_s
    name
  end
end
