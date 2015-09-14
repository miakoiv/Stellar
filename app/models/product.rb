#encoding: utf-8

class Product < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Customizable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]

  #---
  belongs_to :store
  belongs_to :category
  has_many :inventory_items, -> (product) {
    joins(:product).where('products.store_id = inventory_items.store_id')
  }
  has_many :order_items
  has_many :relationships, dependent: :destroy
  has_many :components, through: :relationships

  scope :available, -> { where '(deleted_at IS NULL OR deleted_at > :today) AND NOT (available_at IS NULL OR available_at > :today)', today: Date.current }
  scope :categorized, -> { where.not(category_id: nil) }
  scope :uncategorized, -> { where(category_id: nil) }
  scope :virtual, -> { where(virtual: true) }

  #---
  validates :store_id, presence: true
  validates :code, presence: true
  validates :title, presence: true

  #---
  def available?
    (deleted_at.nil? || deleted_at.future?) &&
    !(available_at.nil? || available_at.future?)
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
