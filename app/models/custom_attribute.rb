#encoding: utf-8

class CustomAttribute < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  belongs_to :measurement_unit
  has_many :custom_values, dependent: :destroy

  #---
  validates :name, presence: true

  #---
  def value_tags
    custom_values.map(&:to_s).join(',')
  end

  def to_s
    name
  end
end
