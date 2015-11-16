#encoding: utf-8

class Customization < ActiveRecord::Base

  belongs_to :customizable, polymorphic: true
  belongs_to :custom_attribute
  belongs_to :custom_value

  #---
  def value
    custom_value.present? ? custom_value.value : self[:value]
  end

  def value_with_units
    "#{value} #{custom_attribute.measurement_unit}"
  end

end
