#encoding: utf-8

class MeasurementUnit < ActiveRecord::Base

  belongs_to :base_unit, class_name: 'MeasurementUnit'

  #---
  def factor
    base_unit.nil? ? 1 : 10 ** exponent
  end

  def pricing_base
    base_unit || self
  end

  def to_s
    name
  end

end
