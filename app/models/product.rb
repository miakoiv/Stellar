#encoding: utf-8

class Product < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]

  enum purpose: {vanilla: 0, master: 1, variant: 2, compound: 3, virtual: 4}

  # Monetize product attributes.
  monetize :cost_price_cents, allow_nil: true
  monetize :trade_price_cents, allow_nil: true
  monetize :retail_price_cents, allow_nil: true

  # Monetize aggregate methods.
  monetize :price_cents, disable_validation: true
  monetize :unit_price_cents, disable_validation: true

  INLINE_SEARCH_RESULTS = 20

  # Additional sorting scopes through Reorderable.
  define_scope :alphabetical do
    order(:title, :subtitle)
  end
  define_scope :retail_price_asc do
    order(retail_price_cents: :asc)
  end
  define_scope :retail_price_desc do
    order(retail_price_cents: :desc)
  end

  #---
  belongs_to :store

  # A product may belong to multiple categories, and must update its own
  # timestamp when the relationships change.
  has_and_belongs_to_many :categories, after_add: :touch_self, after_remove: :touch_self

  # Product may form master-variant relationships, and any change will
  # trigger a timestamp update.
  belongs_to :master_product, class_name: 'Product', inverse_of: :variants
  has_many :variants, class_name: 'Product', foreign_key: :master_product_id, inverse_of: :master_product, after_add: :touch_self, after_remove: :touch_self

  has_many :inventory_items, -> (product) {
    joins(:product).where('products.store_id = inventory_items.store_id')
  }

  has_many :order_items
  has_many :component_entries, dependent: :destroy
  has_many :component_products, through: :component_entries, source: :component
  has_many :requisite_entries, dependent: :destroy
  has_many :requisite_products, through: :requisite_entries, source: :requisite
  has_many :product_properties, dependent: :destroy
  has_many :properties, through: :product_properties
  has_many :promoted_items
  has_many :promotions, through: :promoted_items
  has_many :iframes, dependent: :destroy

  # Alternate retail prices in pricing groups.
  has_many :alternate_prices, dependent: :destroy

  # Customer assets referring to this product.
  has_many :customer_assets

  scope :real, -> { where.not(purpose: purposes[:virtual]) }
  scope :live, -> { where(live: true) }
  scope :undead, -> { where(live: false) }

  # Products on display are shown in storefront views. Vanilla products are
  # directly purchasable, master products link to their first variant, and
  # compound products will split into their components when purchased.
  scope :on_display, -> {
    where(purpose: [:vanilla, :master, :compound].map { |p| purposes[p] })
  }

  scope :with_assets, -> { joins(:customer_assets).distinct }

  #---
  validates :code, presence: true, uniqueness: {scope: :store}
  validates :title, presence: true

  #---
  # This attribute allows adding requisite entries en masse
  # through a string of comma-separated ids.
  attr_accessor :requisite_ids_string

  #---
  before_save :reset_live
  after_save :touch_categories

  #---
  def self.purpose_options
    purposes.keys.map { |p| [Product.human_attribute_value(:purpose, p), p] }
  end

  # Options for a search form.
  def self.availability_options
    [
      [human_attribute_name(:live), true],
      [human_attribute_name(:not_live), false]
    ]
  end

  #---
  def real?; !virtual? end
  def undead?; !live? end

  # Finds the first variant for this product in the scope of given category.
  # Returns self if not a master product or there are no variants.
  def first_variant(category)
    master? && variants.sorted(category.product_scope).first || self
  end

  def sibling_variants
    master_product.variants - [self]
  end

  # Finds product properties that differ from the baseline established
  # by given product. Properties unique to this product are retained.
  def distinct_properties(product)
    baseline = product.product_properties_hash
    product_properties.select { |product_property|
      baseline[product_property.property_id] != product_property.value
    }
  end

  # Finds the set of unique properties across all variants of a master product.
  # Returns a hash keyed by property, or an empty set if not a master product.
  def unique_properties
    return [] unless master?
    variants.includes(product_properties: :property).map(&:product_properties)
      .flatten.group_by(&:property).select { |p, v| v.uniq(&:value).count > 1 }
  end

  # If a single category is requested, give the first live one.
  def category
    categories.live.first
  end

  def searchable_product_properties
    product_properties.joins(:property).merge(Property.searchable).merge(Property.sorted)
  end

  # Assigned product properties as a hash keyed by property id.
  # Useful for comparison, see #distinct_properties.
  def product_properties_hash
    product_properties.pluck(:property_id, :value).to_h
  end

  def active_promoted_items
    promoted_items.joins(:promotion).merge(Promotion.active)
  end

  # Finds the promoted item with the lowest quoted price.
  def best_promoted_item
    lowest = active_promoted_items.pluck(:price_cents).compact.min
    return nil if lowest.nil?
    active_promoted_items.find_by(price_cents: lowest)
  end

  # Returns the retail price in given pricing group. If no group is specified,
  # finds the lowest retail price through promotions.
  def price_cents(pricing_group)
    if pricing_group.present?
      return alternate_prices.find_by(pricing_group: pricing_group).try(:retail_price_cents) || retail_price_cents
    end
    lowest = best_promoted_item
    return lowest.price_cents if lowest.present?
    retail_price_cents
  end

  # Calculates unit price from given total cents by finding a product
  # property that declares unit pricing.
  def unit_price_cents(total_cents)
    return nil if total_cents.nil?
    product_property = unit_pricing_property
    return nil if product_property.nil? || product_property.value.nil?
    measure = product_property.value.tr(',', '.').to_f
    return nil if measure == 0
    total_cents / (measure * product_property.property.measurement_unit.factor)
  end

  # Returns the unit (if any) that unit pricing is based on.
  def base_unit
    product_property = unit_pricing_property
    return nil if product_property.nil?
    product_property.property.measurement_unit.pricing_base
  end

  # Markup percentage from trade price to retail price.
  def markup_percent
    return nil if trade_price.nil? || retail_price.nil? || trade_price == 0
    100 * (retail_price - trade_price) / trade_price
  end

  # Margin percentage from trade price to retail price.
  def margin_percent
    return nil if trade_price.nil? || retail_price.nil? || retail_price == 0
    100 * (retail_price - trade_price) / retail_price
  end

  # Gathers product stock to a hash keyed by inventory.
  # Values are inventory items.
  def stock
    inventory_items.includes(:inventory).group_by(&:inventory)
      .map { |inventory, items| [inventory, items.first] }.to_h
  end

  # Product is considered available when it's live. In reality,
  # stock should be consulted here, but we don't exactly know
  # which inventory would apply.
  def available?
    live?
  end

  def master_product_options
    store.products.master.map { |p| [p.to_s, p.id] }
  end

  def available_variant_options
    store.products.variant.map { |p| [p.to_s, p.id] }
  end

  # Creates a duplicate of this product, including associations.
  def duplicate!
    clone = dup.tap do |c|
      c.reset_code
      c.save
      c.update(
        categories: categories,
        variants: variants,
        component_products: component_products,
        requisite_products: requisite_products,
        iframes: iframes.map(&:dup),
        alternate_prices: alternate_prices.map(&:dup),
        product_properties: product_properties.map(&:dup)
      )
      images.each do |image|
        c.images.create(
          priority: image.priority,
          purpose: image.purpose,
          attachment: image.attachment
        )
      end
    end
  end

  def slugger
    [[:title, :subtitle, :code], [:title, :subtitle, :code, -> { store.name }]]
  end

  def should_generate_new_friendly_id?
    (title_changed? || subtitle_changed? || code_changed?) || super
  end

  def with_requisite_products
    [self] + requisite_products
  end

  # Icon name based on purpose.
  def icon
    [nil, 'square', 'sitemap', 'archive', 'magic'][Product.purposes[purpose]]
  end

  def to_s
    "#{title} #{subtitle}"
  end

  protected
    def touch_self(category)
      self.touch if persisted?
    end

    def touch_categories
      categories.each(&:touch)
    end

    # Adds an incrementing branch number to the product code.
    def reset_code
      while !valid?
        trunk, branch = code.partition(/ \(\d+\)/)
        branch = ' (0)' if branch.empty?
        self[:code] = "#{trunk}#{branch.succ}"
      end
    end

    # Resets the live status of the product, according to these criteria:
    # - must have at least one live category
    # - set to be available at a certain date which is not in the future
    # - if set to be deleted at a certain date which is in the future
    def reset_live
      self[:live] = categories.live.any? &&
        (available_at.present? && !available_at.future?) &&
        (deleted_at.nil? || deleted_at.future?)
      true
    end

    private
      def unit_pricing_property
        product_properties.joins(:property).merge(Property.unit_pricing).first
      end
end
