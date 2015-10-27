#encoding: utf-8

class Customization < ActiveRecord::Base

  belongs_to :customizable, polymorphic: true
  belongs_to :custom_attribute
  belongs_to :custom_value

  #---
  def value_with_units
    if custom_attribute.set?
      custom_value.to_s
    else
      "#{value} #{custom_attribute.measurement_unit}"
    end
  end

end
