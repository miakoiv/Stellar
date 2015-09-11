#encoding: utf-8

class Category < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :history]

  #---
  belongs_to :store
  belongs_to :parent_category, class_name: 'Category'
  has_many :sub_categories, class_name: 'Category', foreign_key: :parent_category_id
  has_many :products

  #---
  validates :name, presence: true

  #---
  def slugger
    [:name, [:name, -> { store.name }]]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_s
    name
  end
end
