#encoding: utf-8

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
    sort_attribute = numeric? ? :value_f : :value
    product_properties.order(sort_attribute).pluck(:value).uniq
  end

  def values_for(scope)
    sort_attribute = numeric? ? :value_f : :value
    product_properties.joins(:product).merge(scope).order(sort_attribute).
      pluck(:value).uniq
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
