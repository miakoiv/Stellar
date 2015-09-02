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
  has_many :relationships, dependent: :destroy
  has_many :components, through: :relationships

  scope :available, -> { where '(deleted_at IS NULL OR deleted_at > :today) AND NOT (available_at IS NULL OR available_at > :today)', today: Date.current }
  scope :categorized, -> { where.not(category_id: nil) }
  scope :uncategorized, -> { where(category_id: nil) }

  #---
  validates :store_id, presence: true
  validates :code, presence: true
  validates :title, presence: true

  #---
  def available?
    (deleted_at.nil? || deleted_at.future?) &&
    !(available_at.nil? || available_at.future?)
  end

  def to_s
    title
  end
end
