#encoding: utf-8
#
# Promotions of one or more promoted items that run from first_date
# to last_date. The business logic of the promotion is defined by its
# promotion handler it belongs to.
#
class Promotion < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  belongs_to :promotion_handler
  has_many :promoted_items, dependent: :destroy
  has_many :products, through: :promoted_items

  scope :active, -> { where '(first_date IS NULL OR first_date <= :today) AND (last_date IS NULL OR last_date >= :today)', today: Date.current }

  #---
  validates :name, presence: true

  #---
  # These attributes allow adding products and categories en masse
  # through a string of comma-separated ids.
  attr :product_ids_string, :category_ids_string

  #---
  def matching_items(order)
    # This method takes an order object and should return the order items
    # that match the products this promotion is promoting.
  end

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
