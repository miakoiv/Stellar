#encoding: utf-8

class Category < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]
  acts_as_nested_set scope: :store,
                     dependent: :nullify,
                     counter_cache: :children_count,
                     touch: true

  #---
  belongs_to :store
  has_and_belongs_to_many :products
  belongs_to :banner, class_name: 'Page'

  # Categories may appear at any number of portal departments.
  has_and_belongs_to_many :departments

  default_scope { order(:lft) }
  scope :live, -> { where(live: true) }
  scope :visible, -> { where(live: true, hidden: false) }

  #---
  validates :name, presence: true
  validates :product_scope, presence: true

  #---
  after_save :reset_live_status_of_products!

  #---
  # Category is inside another category if it's the category itself,
  # or one of its descendants.
  def inside?(category)
    category == self || is_descendant_of?(category)
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

  def description
    name
  end

  def to_option
    self_and_ancestors.join " \u23f5 "
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
