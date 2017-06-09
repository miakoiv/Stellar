#encoding: utf-8

class ProductProperty < ActiveRecord::Base

  belongs_to :product, touch: true
  belongs_to :property
  delegate :string?, :numeric?, to: :property

  default_scope { joins(:property).merge(Property.sorted) }

  #---
  # Override value setter to convert numeric representations.
  def value=(string)
    self[:value] = string
    numeric = string.gsub(/[^\d,.-]/, '').sub(',', '.')
    self[:value_i] = numeric.to_i
    self[:value_f] = numeric.to_f
  end

  def value_with_units(spacing = true)
    return value if property.measurement_unit.nil?
    (spacing ? "%s %s" : "%s%s") % [value, property.measurement_unit]
  end

  def to_s
    "#{property} #{value_with_units}"
  end
end
