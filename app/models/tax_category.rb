#encoding: utf-8

class TaxCategory < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store

  #---
  validates :name, presence: true
  validates :rate, numericality: {greater_than_or_equal_to: 0, less_than: 100}

  #---
  def to_s
    name
  end
end
