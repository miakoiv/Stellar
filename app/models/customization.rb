#encoding: utf-8

class Customization < ActiveRecord::Base

  belongs_to :customizable, polymorphic: true
  belongs_to :custom_attribute
  belongs_to :custom_value

  # The multiple-selection widget we use for customizations
  # posts an array of ids as custom_value_ids.
  attr_accessor :custom_value_ids

end
