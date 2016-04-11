#encoding: utf-8

class PricingGroup < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  has_many :alternate_prices, dependent: :destroy

  default_scope -> { order(:name) }

  #---
  validates :name, presence: true, uniqueness: {scope: :store}

  #---
  def to_s
    name
  end
end
