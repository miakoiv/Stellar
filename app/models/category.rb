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
  belongs_to :parent, class_name: 'Category'
  has_many :children, class_name: 'Category', foreign_key: :parent_id
  has_and_belongs_to_many :products
  belongs_to :banner, class_name: 'Page'

  # Categories may appear at any number of portal departments.
  has_and_belongs_to_many :departments

  default_scope { sorted }
  scope :live, -> { where(live: true) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :visible, -> { where(live: true, hidden: false) }

  #---
  validates :name, presence: true
  validates :product_scope, presence: true

  #---
  after_save :reset_live_status_of_products!

  #---
  # Category is inside another category if it's the category itself,
  # or inside one of its parent categories.
  def inside?(category)
    category == self || parent.present? && parent.inside?(category)
  end

  def level
    parent.nil? ? 0 : 1 + parent.level
  end

  def top_level
    parent.nil? ? self : parent.top_level
  end

  def visible?
    live? && !hidden?
  end

  # If this category has no products, tries the first child category.
  # Defaults to self if there are no child categories, or the first
  # child category has no products either.
  def having_products
    return self if children.visible.empty? || products.visible.any?
    first_child = children.visible.first
    first_child.products.visible.empty? ? self : first_child
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

  def description
    name
  end

  def to_s
    name
  end

  private
    def reset_live_status_of_products!
      products.each do |product|
        product.reset_live_status!
      end
    end
end
