#encoding: utf-8

class Brand < ActiveRecord::Base

  has_many :products

  def to_s
    name
  end
end
