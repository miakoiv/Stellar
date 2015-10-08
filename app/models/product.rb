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
  belongs_to :category
  has_many :inventory_items, -> (product) {
    joins(:product).where('products.store_id = inventory_items.store_id')
  }
  has_many :order_items
  has_many :relationships, dependent: :destroy
  has_many :components, through: :relationships
  has_many :promoted_item
  has_many :promotions, through: :promoted_item
  has_many :iframes, dependent: :destroy

  scope :available, -> { where '(deleted_at IS NULL OR deleted_at > :today) AND NOT (available_at IS NULL OR available_at > :today)', today: Date.current }
  scope :categorized, -> { where.not(category_id: nil) }
  scope :uncategorized, -> { where(category_id: nil) }
  scope :virtual, -> { where(virtual: true) }

  #---
  validates :code, presence: true
  validates :title, presence: true

  #---
  def available?
    (deleted_at.nil? || deleted_at.future?) &&
    !(available_at.nil? || available_at.future?)
  end

  # Checks assigned customizations for an attribute that declares unit pricing,
  # returns calculated price per base unit.
  def unit_price
    customization = unit_pricing_customization
    return nil if sales_price.nil? || customization.nil?
    sales_price / (customization.custom_value.to_i * customization.custom_attribute.measurement_unit.factor)
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

  def to_s
    title
  end
end
