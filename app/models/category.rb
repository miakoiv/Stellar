#encoding: utf-8

class Category < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]
  acts_as_nested_set scope: :store,
                     dependent: :destroy,
                     counter_cache: :children_count,
                     touch: true

  #---
  belongs_to :store
  has_and_belongs_to_many :products

  has_one :page, as: :resource, dependent: :destroy

  # Categories may appear at any number of portal departments.
  has_and_belongs_to_many :departments

  scope :live, -> { where(live: true) }

  #---
  validates :name, presence: true
  validates :product_scope, presence: true

  #---
  # Finds the first live category with visible products.
  def self.first_with_products
    live.find { |category| category.products.visible.any? }
  end

  #---
  # Category is inside another category if it's the category itself,
  # or one of its descendants.
  def inside?(category)
    category == self || is_descendant_of?(category)
  end

  # Finds the first live descendant category with visible products if this one
  # has none. Defaults to self if descendants contain no visible products.
  def first_with_products
    return self if products.visible.any?
    first = descendants.live.first_with_products
    return first || self
  end

  def slugger
    [:name, [:name, -> { store.name }]]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def description
    name
  end

  def to_option
    self_and_ancestors.join " \u23f5 "
  end

  def to_s
    name
  end
end
