#encoding: utf-8

class Product < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Customizable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]
  monetize :cost_cents, allow_nil: true
  monetize :sales_price_cents, allow_nil: true

  INLINE_SEARCH_RESULTS = 20

  # Additional sorting scopes through Reorderable.
  define_scope :alphabetical do
    order(:title, :subtitle)
  end
  define_scope :sales_price_asc do
    order(sales_price_cents: :asc)
  end
  define_scope :sales_price_desc do
    order(sales_price_cents: :desc)
  end

  #---
  belongs_to :store
  has_and_belongs_to_many :categories
  after_save { categories.each(&:touch) }
  has_many :inventory_items, -> (product) {
    joins(:product).where('products.store_id = inventory_items.store_id')
  }
  has_many :order_items
  has_many :relationships, dependent: :destroy
  has_many :components, through: :relationships
  has_many :product_properties, dependent: :destroy
  has_many :properties, through: :product_properties
  after_touch do |product|
    tags = product.product_properties
        .joins(:property).merge(Property.searchable).map { |s|
          s.value_with_units(false)
        }
    product.update search_tags: tags.join(' ')
  end

  has_many :promoted_items
  has_many :promotions, through: :promoted_items
  has_many :iframes, dependent: :destroy

  # Self-referential HABTM to link products together.
  has_and_belongs_to_many :linked_products, class_name: 'Product', join_table: :linked_products_products, foreign_key: :product_id, association_foreign_key: :linked_product_id

  scope :available, -> { where '(deleted_at IS NULL OR deleted_at > :today) AND NOT (available_at IS NULL OR available_at > :today)', today: Date.current }
  scope :categorized, -> { includes(:categories).where.not(categories: {id: nil}) }
  scope :uncategorized, -> { includes(:categories).where(categories: {id: nil}) }
  scope :virtual, -> { where(virtual: true) }

  ransacker :keyword do |parent|
    Arel::Nodes::NamedFunction.new('CONCAT_WS', [Arel::Nodes.build_quoted(' '), parent.table[:title], parent.table[:subtitle]])
  end

  ransacker :sales_price, formatter: -> (v) { Monetize.parse(v).cents } do |parent|
    parent.table[:sales_price_cents]
  end

  ransacker :available do |parent|
    Arel.sql('((deleted_at IS NULL OR deleted_at > CURRENT_DATE()) AND NOT (available_at IS NULL OR available_at > CURRENT_DATE()))')
  end

  #---
  validates :code, presence: true
  validates :title, presence: true

  #---
  def property_value(property_id)
    product_properties.where(property_id: property_id).first.try(:value_with_units)
  end

  # If a single category is requested, give the first one.
  def category
    categories.first
  end

  def available?
    (deleted_at.nil? || deleted_at.future?) &&
    !(available_at.nil? || available_at.future?)
  end

  # Checks assigned customizations for an attribute that declares unit pricing,
  # returns calculated price per base unit.
  def unit_price
    customization = unit_pricing_customization
    measure = customization.try(:value).to_i
    return nil if sales_price.nil? || customization.nil? || measure == 0
    sales_price / (measure * customization.custom_attribute.measurement_unit.factor)
  end

  # Returns the unit (if any) that unit pricing is based on.
  def base_unit
    customization = unit_pricing_customization
    return nil if customization.nil?
    customization.custom_attribute.measurement_unit.base_unit
  end

  # Gathers product stock to a hash keyed by inventory.
  # Values are inventory items.
  def stock
    inventory_items.group_by(&:inventory)
      .map { |inventory, items| [inventory, items.first] }.to_h
  end

  def slugger
    [[:title, :subtitle, :code], [:title, :subtitle, :code, -> { store.name }]]
  end

  def should_generate_new_friendly_id?
    (title_changed? || subtitle_changed? || code_changed?) || super
  end

  def with_linked_products
    [self] + linked_products
  end

  def linked_product_options
    (store.products.categorized - [self]).map { |p| [p.to_s, p.id] }
  end

  def tab_name
    category.present? ? category.name : 'uncategorized'
  end

  def to_s
    "#{title} #{subtitle}"
  end
end
