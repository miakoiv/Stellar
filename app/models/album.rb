#encoding: utf-8

class Album < ApplicationRecord

  resourcify
  include Authority::Abilities
  include Pictureable

  #---
  belongs_to :store

  default_scope { order(created_at: :desc) }

  #---
  validates :title, presence: true

  #---
  def to_s
    title
  end
end
