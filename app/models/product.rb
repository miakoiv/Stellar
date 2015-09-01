#encoding: utf-8

class Product < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Customizable
  include Reorderable

  #---
  belongs_to :store
  belongs_to :category
  has_many :inventory_items

  has_many :relationships, -> (product) {
    joins(:product).where(products: {store_id: product.store_id})
  }, foreign_key: :parent_code, primary_key: :code

  has_many :components, through: :relationships, class_name: 'Product', source: :product

  scope :available, -> { where(deleted_at: nil).where('available_at <= ?', Date.current) }
  scope :categorized, -> { where.not(category_id: nil) }
  scope :uncategorized, -> { where(category_id: nil) }

  #---
  validates :store_id, presence: true
  validates :code, presence: true
  validates :title, presence: true

  #---
  def available?
    deleted_at.nil? && !(available_at.nil? || available_at.future?)
  end

  def to_s
    title
  end
end
