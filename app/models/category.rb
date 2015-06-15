#encoding: utf-8

class Category < ActiveRecord::Base

  belongs_to :parent_category, class_name: 'Category'
  has_many :sub_categories, class_name: 'Category', foreign_key: :parent_category_id
  has_many :products


  def self.options
    all.map { |c| [c.name, c.id] }
  end


  def to_s
    name
  end
end
