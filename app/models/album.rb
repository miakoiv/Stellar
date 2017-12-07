#encoding: utf-8

class Album < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Imageable

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
