#encoding: utf-8

class ProductProperty < ActiveRecord::Base

  belongs_to :product, touch: true
  belongs_to :property

  #---
  def value_with_units(spacing = true)
    return value if property.measurement_unit.nil?
    (spacing ? "%s %s" : "%s%s") % [value, property.measurement_unit]
  end

  def to_s
    "#{property} #{value_with_units}"
  end
end
