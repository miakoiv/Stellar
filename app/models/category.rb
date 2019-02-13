class Category < ApplicationRecord

  resourcify
  include Authority::Abilities
  include Trackable
  include Pictureable
  include Pageable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :scoped, :history], scope: :store
  acts_as_nested_set scope: :store,
                     dependent: :destroy,
                     counter_cache: :children_count,
                     touch: true

  VIEW_MODES = [
    'product-grid',
    'product-list'
  ].freeze

  #---
  belongs_to :store
  has_and_belongs_to_many :products

  # Categories may appear at any number of portal departments.
  has_and_belongs_to_many :departments

  scope :live, -> { where(live: true) }

  #---
  validates :name, presence: true
  validates :product_scope, presence: true
  validates :view_mode, presence: true

  #---
  def self.self_and_descendant_ids(id)
    find(id).self_and_descendants.pluck(:id)
  end

  def self.options_for_select(categories)
    [].tap do |options|
      each_with_level(categories.order(:lft)) do |c, l|
        options << yield(c, l)
      end
    end
  end

  def self.view_mode_options
    VIEW_MODES.map { |m| [Category.human_attribute_value(:view_mode, m), m] }
  end

  #---
  # Category is inside another category if it's the category itself,
  # or one of its descendants.
  def inside?(category)
    category == self || is_descendant_of?(category)
  end

  def self_and_maybe_descendants
    filtering ? self_and_descendants : Category.where(id: self)
  end

  def slugger
    [:name, [:name, :id]]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def description
    name
  end

  def to_option
    "%s%s" % ["\u00a0\u00a0\u00a0\u00a0" * depth, to_s]
  end

  def to_path
    self_and_ancestors.join " \u23f5 "
  end

  def to_s
    name
  end
end
