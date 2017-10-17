#encoding: utf-8

class Group < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Reorderable

  # This group purchases products at price base plus markup.
  enum price_base: {retail: 1, trade: 2, cost: 3}

  APPEARANCES = [
    :default, :success, :info, :warning, :danger
  ].freeze

  #---
  belongs_to :store
  has_and_belongs_to_many :users

  # Group-specific prices for products.
  has_many :alternate_prices

  # Categories the group members are limited to, if any.
  has_and_belongs_to_many :categories

  default_scope { sorted }
  scope :at, -> (store) { where(store: store) }

  #---
  validates :name, presence: true

  #---
  def self.appearance_options
    APPEARANCES.map { |a| [human_attribute_value(:appearance, a), a, data: {appearance: a}.to_json] }
  end

  def self.price_base_options
    price_bases.keys.map { |p| [human_attribute_value(:price_base, p), p] }
  end

  #---
  def price_method
    "#{price_base}_price".to_sym
  end

  # Categories available to this group when creating and editing products.
  def available_categories(store)
    categories.any? ? categories.order(:lft) : store.categories.order(:lft)
  end

  def category_options(store)
    available_categories(store).map { |c| [c.to_option, c.id] }
  end

  def notified_users
    users.with_role(:order_notify, store)
  end

  def to_s
    name
  end
end
