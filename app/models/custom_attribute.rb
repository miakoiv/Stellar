#encoding: utf-8

class CustomAttribute < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  # Custom attributes come in set and scalar flavours. Sets have user defined
  # associated custom values. Numeric and alpha attributes have no attached
  # custom value object, the values are stored directly in customizations.
  enum attribute_type: {set: 0, numeric: 1, alpha: 2}

  #---
  belongs_to :store

  # A measurement unit may be selected for numeric attributes.
  belongs_to :measurement_unit

  # Sets may have any number of custom values.
  has_many :custom_values, dependent: :destroy

  # Searchable attributes are included in product searching and filtering.
  scope :searchable, -> { where(searchable: true) }

  #---
  validates :name, presence: true

  #---
  def type_name
    human_attribute_value(:attribute_type)
  end

  def name_with_units
    measurement_unit.present? ? "#{name} (#{measurement_unit})" : name
  end

  def to_s
    name
  end
end
