#encoding: utf-8

class Order < ActiveRecord::Base

  belongs_to :user
  belongs_to :order_type


  def to_s
    "[#{created_at.to_s(:long)}] #{user}"
  end
end
