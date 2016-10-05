#encoding: utf-8

class TaxCategory < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Reorderable

  #---
  belongs_to :store

  default_scope { sorted }

  #---
  validates :name, presence: true
  validates :rate, numericality: {greater_than_or_equal_to: 0, less_than: 100}

  #---
  def to_s
    name
  end
end
