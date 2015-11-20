#encoding: utf-8

class Customization < ActiveRecord::Base

  belongs_to :customizable, polymorphic: true
  belongs_to :custom_attribute
  belongs_to :custom_value

  # Customizations matching given attribute, value combination where
  # attribute is of type set, and value is a comma separated list of ids.
  scope :by_set, -> (attribute, value) {
    joins(:custom_attribute).where(custom_attributes: {name: attribute}).where(custom_value_id: value.split(',')).select(:id).pluck(:id)
  }

  #---
  def display_value
    custom_value.present? ? custom_value.value : value
  end

  def display_value_with_units
    "#{display_value} #{custom_attribute.measurement_unit}"
  end

end
