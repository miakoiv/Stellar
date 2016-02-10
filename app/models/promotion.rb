#encoding: utf-8
#
# Promotions of one or more promoted items that run from first_date
# to last_date. The business logic of the promotion is defined by its
# promotion handler that is created on the creation of the promotion.
#
class Promotion < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  has_many :promoted_items, dependent: :destroy
  has_many :products, through: :promoted_items
  has_one :promotion_handler, dependent: :destroy
  accepts_nested_attributes_for :promotion_handler

  scope :active, -> { where '(first_date IS NULL OR first_date <= :today) AND (last_date IS NULL OR last_date >= :today)', today: Date.current }

  #---
  validates :name, presence: true

  #---
  # These attributes allow adding products and categories en masse
  # through a string of comma-separated ids.
  attr_accessor :product_ids_string, :category_ids_string

  #---
  # When a promotion is created, its promotion handler type is set to one
  # of the PromotionHandler subclasses below. An object of this type is
  # created an associated with the promotion.
  def self.handler_types
    [
      'PromotionHandler::Vanilla',
      'PromotionHandler::FreebieBundle'
    ]
  end

  #---
  # Whether prices can be set on promoted items depends on the handler.
  delegate :editable_prices?, to: :promotion_handler

  # Takes an order object and returns order items that match this promotion.
  def matching_items(order)
    order.order_items.where(product_id: promoted_items.pluck(:product_id))
  end

  # Applies this promotion to the given order.
  def apply!(order)
    promotion_handler.apply!(order)
  end

  def available_products
    store.products.live - products
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
