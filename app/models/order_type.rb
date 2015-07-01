#encoding: utf-8

class OrderType < ActiveRecord::Base

  # Orders of this type refer to stock in this particular inventory.
  belongs_to :inventory

  has_many :orders


  def self.options
    all.map { |i| [i.name, i.id] }
  end


  def to_s
    name
  end
end
