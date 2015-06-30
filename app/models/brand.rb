#encoding: utf-8

class Brand < ActiveRecord::Base

  include Imageable

  before_create :assign_slug

  has_many :categories
  has_many :products
  has_many :users
  has_many :inventories
  has_many :order_types, through: :inventories

  validates :name, presence: true
  validates :erp_number, numericality: true


  def category_options
    categories.map { |c| [c.name, c.id] }
  end

  def to_s
    new_record? ? 'New brand' : name
  end

  private
    def assign_slug
      self.slug = name.parameterize
    end

end
