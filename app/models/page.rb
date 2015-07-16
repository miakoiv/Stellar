#encoding: utf-8

class Page < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable
  include Reorderable

  belongs_to :store
  belongs_to :parent_page, class_name: 'Page'


  def to_s
    new_record? ? 'New page' : title
  end
end
