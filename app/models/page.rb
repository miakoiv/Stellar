#encoding: utf-8

class Page < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable
  include FriendlyId
  friendly_id :title, use: [:slugged, :history]

  #---
  belongs_to :store
  belongs_to :parent_page, class_name: 'Page'
  has_many :sub_pages, class_name: 'Page', foreign_key: :parent_page_id
  has_and_belongs_to_many :albums

  scope :top_level, -> { where(parent_page_id: nil) }
  scope :navbar, -> { where(navbar: true) }

  #---
  validates :title, presence: true

  #---
  # Prevent FriendlyId from changing slugs on internal pages.
  def should_generate_new_friendly_id?
    !internal? && title_changed? || super
  end

  def to_s
    title
  end
end
