#encoding: utf-8

class Department < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :slugger, use: [:slugged, :scoped, :history], scope: :store

  #---
  belongs_to :store

  # Departments may be connected to any number of product categories.
  has_and_belongs_to_many :categories, -> { merge(Category.live) }
  has_many :products, through: :categories

  has_one :page, as: :resource, dependent: :destroy

  default_scope { sorted }

  #---
  validates :name, presence: true

  #---
  def slugger
    [:name, [:name, :id]]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_s
    name
  end
end
