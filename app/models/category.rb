#encoding: utf-8

class Category < ActiveRecord::Base

  belongs_to :brand
  belongs_to :parent_category, class_name: 'Category'
  has_many :sub_categories, class_name: 'Category', foreign_key: :parent_category_id
  has_many :images, as: :imageable
  has_many :products

  validates :name, presence: true


  def self.options
    all.map { |c| [c.name, c.id] }
  end


  def to_s
    new_record? ? 'New category' : name
  end
end
