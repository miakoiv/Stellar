#encoding: utf-8

class Category < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]

  #---
  belongs_to :store
  belongs_to :parent_category, class_name: 'Category'
  has_many :subcategories, class_name: 'Category', foreign_key: :parent_category_id
  has_and_belongs_to_many :products

  scope :live, -> { where(live: true) }
  scope :top_level, -> { where(parent_category_id: nil) }

  #---
  validates :name, presence: true
  validates :product_scope, presence: true

  #---
  # Category is inside another category if it's the category itself,
  # or inside one of its parent categories.
  def inside?(category)
    category == self || parent_category.present? && parent_category.inside?(category)
  end

  def level
    parent_category.nil? ? 0 : 1 + parent_category.level
  end

  def top_level
    parent_category.nil? ? self : parent_category.top_level
  end

  # If this category has no products, tries the first subcategory.
  # Defaults to self if there are no subcategories, or the first
  # subcategory has no products either.
  def having_products
    return self if subcategories.empty? || products.any?
    first_subcategory = subcategories.sorted.first
    first_subcategory.products.empty? ? self : first_subcategory
  end

  def slugger
    [:name, [:name, -> { store.name }]]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def indented_name
    "#{'    ' * level}#{name}"
  end

  def to_s
    name
  end
end
