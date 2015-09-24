#encoding: utf-8
#
# Promotions of one or more promoted items that run from first_date
# to last_date. The business logic of the promotion is defined in a
# separate class that the promotion declares as its promotion_class.
#
class Promotion < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  has_many :promoted_items
  has_many :products, through: :promoted_items

  scope :active, -> { where '(first_date IS NULL OR first_date <= :today) AND (last_date IS NULL OR last_date >= :today)', today: Date.current }

  #---
  validates :promotion_class, presence: true
  validates :name, presence: true

  #---
  def available_products
    store.products.categorized.available - products
  end

  def available_categories
    store.categories
  end

  def active?
    (first_date.nil? || !first_date.future?) &&
    (last_date.nil? || !last_date.past?)
  end

  def to_s
    name
  end
end
