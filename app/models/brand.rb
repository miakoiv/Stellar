#encoding: utf-8

class Brand < ActiveRecord::Base

  has_many :products
  has_many :users
  has_many :inventories
  has_many :order_types, through: :inventories

  validates :name, presence: true


  def self.options
    all.map { |b| [b.name, b.id] }
  end


  def to_s
    new_record? ? 'New brand' : name
  end
end
