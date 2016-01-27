#encoding: utf-8

class Product < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]
  monetize :cost_cents, allow_nil: true
  monetize :sales_price_cents, allow_nil: true
  monetize :user_price_cents, disable_validation: true
  monetize :user_unit_price_cents, disable_validation: true

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

  scope :live, -> { where(live: true) }
  scope :undead, -> { where(live: false) }
  scope :real, -> { where(virtual: false) }
  scope :virtual, -> { where(virtual: true) }

  #---
  validates :code, presence: true
  validates :title, presence: true

  before_save :reset_live
  after_save :touch_categories

  #---
  def real?; !virtual end
  def undead?; !live end

  # If a single category is requested, give the first one.
  def category
    categories.first
  end

  def searchable_product_properties
    product_properties.joins(:property).merge(Property.searchable).merge(Property.sorted)
  end

  # Price adjusted for given user.
  def user_price_cents(user)
    return nil if sales_price_cents.nil?
    sales_price_cents * user.pricing_factor
  end

  # Checks product properties for a property that declares unit pricing,
  # returns calculated price per base unit, adjusted for given user.
  def user_unit_price_cents(user)
    price = user_price_cents(user)
    product_property = unit_pricing_property
    measure = product_property.try(:value).to_i
    return nil if price.nil? || product_property.nil? || measure == 0
    price / (measure * product_property.property.measurement_unit.factor)
  end

  # Returns the unit (if any) that unit pricing is based on.
  def base_unit
    product_property = unit_pricing_property
    return nil if product_property.nil?
    product_property.property.measurement_unit.pricing_base
  end

  # Gathers product stock to a hash keyed by inventory.
  # Values are inventory items.
  def stock
    inventory_items.group_by(&:inventory)
      .map { |inventory, items| [inventory, items.first] }.to_h
  end

  # Product is considered available when it's live. In reality,
  # stock should be consulted here, but we don't exactly know
  # which inventory would apply.
  def available?
    live?
  end

  # Options for a search form.
  def self.availability_options
    [
      [human_attribute_name(:live), true],
      [human_attribute_name(:not_live), false]
    ]
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
    (store.products.live - [self]).map { |p| [p.to_s, p.id] }
  end

  def tab_name
    category.present? ? category.name : 'uncategorized'
  end

  def to_s
    "#{title} #{subtitle}"
  end

  protected
    def touch_categories
      categories.each(&:touch)
    end

    # Resets the live status of the product, according to these criteria:
    # - must have at least one category
    # - set to be available at a certain date which is not in the future
    # - if set to be deleted at a certain date which is in the future
    def reset_live
      self[:live] = categories.any? &&
        (available_at.present? && !available_at.future?) &&
        (deleted_at.nil? || deleted_at.future?)
      true
    end

    private
      def unit_pricing_property
        product_properties.joins(:property).merge(Property.unit_pricing).first
      end
end
