#encoding: utf-8

class Customization < ActiveRecord::Base

  belongs_to :customizable, polymorphic: true
  belongs_to :custom_attribute
  belongs_to :custom_value

  #---
  def display_value
    custom_value.present? ? custom_value.value : value
  end

  def display_value_with_units
    "#{display_value} #{custom_attribute.measurement_unit}"
  end

end
