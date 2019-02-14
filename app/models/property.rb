class Property < ApplicationRecord

  resourcify
  include Authority::Abilities
  include Trackable
  include Reorderable

  #---
  enum value_type: {string: 0, numeric: 1}

  #---
  belongs_to :store
  belongs_to :measurement_unit, optional: true
  has_many :product_properties, dependent: :destroy
  has_many :products, through: :product_properties

  default_scope { sorted }
  scope :searchable, -> { where(searchable: true) }
  scope :unit_pricing, -> { where(unit_pricing: true) }

  #---
  validates :name, presence: true
  validates :external_name, uniqueness: {scope: :store, allow_blank: true}
  after_save :define_property_search_method, if: -> (property) { property.searchable? }

  #---
  def values
    product_properties.reorder(sort_attribute).pluck(:value).uniq
  end

  def values_for(scope)
    product_properties
      .joins(product: :categories)
      .merge(Product.live)
      .merge(scope)
      .reorder(sort_attribute)
      .pluck(:value)
      .uniq
  end

  def value_counts
    product_properties
      .reorder(sort_attribute)
      .select(sort_attribute)
      .group(sort_attribute)
      .count
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
    def sort_attribute
      numeric? ? :value_f : :value
    end

    def define_property_search_method
      ProductSearch.define_property_search_method(self)
    end
end
