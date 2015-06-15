#encoding: utf-8

class Product < ActiveRecord::Base

  belongs_to :brand
  belongs_to :category

  def to_s
    name
  end
end
