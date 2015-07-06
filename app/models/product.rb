#encoding: utf-8

class Product < ActiveRecord::Base

  include Imageable
  include Reorderable

  belongs_to :brand
  belongs_to :category
  has_many :inventory_items
  has_many :relationships, foreign_key: :parent_id
  has_many :components, through: :relationships, source: :product

  validates :brand_id, presence: true
  validates :code, presence: true
  validates :title, presence: true


  def to_s
    new_record? ? 'New product' : title
  end
end
