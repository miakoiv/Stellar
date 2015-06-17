#encoding: utf-8

class OrderType < ActiveRecord::Base

  has_many :orders


  def to_s
    name
  end
end
