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


  scope :categorized, -> { where.not(category_id: nil) }
  scope :uncategorized, -> { where(category_id: nil) }


  validates :store_id, presence: true
  validates :code, presence: true
  validates :title, presence: true

  # Performs a stock lookup on a product. Returns a hash like
  # {
  #   'manufacturing' => {current: 100, adjustment:  10},
  #   'shipping'      => {current:  50, adjustment: -10}
  # }
  def stock_lookup
    stock = InventoryItem.stock(code)
    OrderItem.adjust_stock!(stock, code)
    stock
  end

  def to_s
    new_record? ? 'New product' : title
  end
end
