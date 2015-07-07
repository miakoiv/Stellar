#encoding: utf-8

class Store < ActiveRecord::Base

  include Imageable

  before_create :assign_slug

  has_many :categories
  has_many :products
  has_many :users

  validates :name, presence: true
  validates :erp_number, numericality: true, allow_blank: true


  def category_options
    categories.map { |c| [c.name, c.id] }
  end

  def to_s
    new_record? ? 'New store' : name
  end

  private
    def assign_slug
      self.slug = name.parameterize
    end
end
