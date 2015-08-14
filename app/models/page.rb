#encoding: utf-8

class Page < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  belongs_to :store
  belongs_to :parent_page, class_name: 'Page'
  has_many :sub_pages, class_name: 'Page', foreign_key: :parent_page_id

  scope :top_level, -> { where(parent_page_id: nil) }


  def to_s
    title
  end
end
