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

  scope :active, -> { where '(promotions.first_date IS NULL OR promotions.first_date <= :today) AND (promotions.last_date IS NULL OR promotions.last_date >= :today)', today: Date.current }

  #---
  validates :name, presence: true
  validates_associated :promoted_items, on: :update

  #---
  # These attributes allow adding products and categories en masse
  # through a string of comma-separated ids.
  attr_accessor :product_ids_string, :category_ids_string

  #---
  # When a promotion is created, its promotion handler type specifies one
  # of the PromotionHandler subclasses as string. An object of this type is
  # created and associated with the promotion.
  def self.handler_types
    [
      'PromotionHandler::Vanilla',
      'PromotionHandler::FreebieBundle'
    ]
  end

  #---
  delegate :description, to: :promotion_handler
  delegate :editable_prices?, to: :promotion_handler

  # Applies this promotion to the given order by calling the promotion
  # handler with the matching items.
  def apply!(order)
    promotion_handler.apply!(matching_items(order))
  end

  # Finds the promoted item matching given order item.
  def item_from_order_item(order_item)
    promoted_items.includes(:product).find_by(product_id: order_item.product_id)
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

  #private

    # Takes an order object and returns order items that match this promotion.
    def matching_items(order)
      order.order_items.includes(:product).where(product_id: promoted_items.pluck(:product_id))
    end
end
