#encoding: utf-8

class ProductProperty < ActiveRecord::Base

  belongs_to :product
  belongs_to :property

  #---
  def value_with_units
    "#{value} #{property.measurement_unit}"
  end
end
