#encoding: utf-8

class Product < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  belongs_to :store
  belongs_to :category
  has_many :inventory_items
  has_many :relationships, -> (product) {
    joins(:product).where(products: {store_id: product.store_id})
  }, foreign_key: :parent_code, primary_key: :code

  validates :store_id, presence: true
  validates :code, presence: true
  validates :title, presence: true


  # Performs a stock lookup on a product. Returns a hash of items like
  # {'manufacturing' => [100, 10], 'shipping' => [50, -10]}
  def stock_lookup
    stock = {}.tap do |stock|
      InventoryItem.where(code: code).each do |item|
        stock[item.inventory.purpose] = {
          current: item.amount || 0,
          adjustment: 0
        }
      end
      OrderItem.joins(:product, order: :order_type)
          .where(products: {code: code}).each do |item|
        order_type = item.order.order_type
        multiplier = order_type.adjustment_multiplier
        stock[order_type.inventory.purpose][:adjustment] += multiplier * item.amount
      end
    end
    stock
  end

  def to_s
    new_record? ? 'New product' : title
  end
end
