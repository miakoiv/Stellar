#encoding: utf-8

# NOTE: migration from CustomAttributes to Properties on production systems:
# mapping = {'numeric' => 'numeric', 'set' => 'string', 'alpha' => 'string'}
# CustomAttribute.all.each { |a| Property.create id: a.id, store_id: a.store_id, value_type: mapping[a.attribute_type], measurement_unit_id: a.measurement_unit_id, unit_pricing: a.unit_pricing, searchable: a.searchable, name: a.name }
# Customization.all.each { |c| ProductProperty.create id: c.id, product_id: c.customizable_id, property_id: c.custom_attribute_id, value: c.display_value }

class Property < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Reorderable

  #---
  enum value_type: {string: 0, numeric: 1}

  #---
  belongs_to :store
  belongs_to :measurement_unit
  has_many :product_properties, dependent: :destroy
  has_many :products, through: :product_properties

  default_scope { sorted }
  scope :searchable, -> { where(searchable: true) }
  scope :unit_pricing, -> { where(unit_pricing: true) }

  #---
  validates :name, presence: true
  after_save :define_search_method

  #---
  def values
    product_properties.pluck(:value).uniq
  end

  def value_type_name
    human_attribute_value(:value_type)
  end

  def name_with_units
    measurement_unit.present? ? "#{name} (#{measurement_unit})" : name
  end

  def sluggify
    "#{name.parameterize.underscore}_#{id}"
  end

  def to_s
    name
  end

  private
    def define_search_method
      ProductSearch.define_search_method(self)
    end
end
