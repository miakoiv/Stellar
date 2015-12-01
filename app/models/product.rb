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

  #---
  belongs_to :store
  has_and_belongs_to_many :categories
  has_many :inventory_items, -> (product) {
    joins(:product).where('products.store_id = inventory_items.store_id')
  }
  has_many :order_items
  has_many :relationships, dependent: :destroy
  has_many :components, through: :relationships
  has_many :product_properties, dependent: :destroy
  has_many :properties, through: :product_properties
  has_many :promoted_items
  has_many :promotions, through: :promoted_items
  has_many :iframes, dependent: :destroy

  # Self-referential HABTM to link products together.
  has_and_belongs_to_many :linked_products, class_name: 'Product', join_table: :linked_products_products, foreign_key: :product_id, association_foreign_key: :linked_product_id

  scope :available, -> { where '(deleted_at IS NULL OR deleted_at > :today) AND NOT (available_at IS NULL OR available_at > :today)', today: Date.current }
  scope :categorized, -> { includes(:categories).where.not(categories: {id: nil}) }
  scope :uncategorized, -> { includes(:categories).where(categories: {id: nil}) }
  scope :virtual, -> { where(virtual: true) }
  scope :by_keyword, -> (keyword) {
    keyword.present? ? where('code LIKE :match OR title LIKE :match OR subtitle LIKE :match', match: "%#{keyword}%") : all
  }

  #---
  validates :code, presence: true
  validates :title, presence: true

  #---
  # Find products matching all of the given search params by iteratively
  # intersecting the current result set with the matches of each search term.
  # Search params are keyed by attribute type (set, numeric, alpha), for example
  # {set: {color: 'white', origin: 'Finland'}, numeric: {width: '100:200'}}
  def self.search(search_params)
    results = all
    search_params.each do |type, terms|
      terms.each do |attribute, values|
        matches = Customization.public_send("by_#{type}", attribute, values)
        results &= includes(:customizations).where(customizations: {id: matches})
      end
    end
    results
  end

  #---
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
