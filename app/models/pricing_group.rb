#encoding: utf-8

class PricingGroup < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  has_many :alternate_prices, dependent: :destroy
  has_and_belongs_to_many :users

  default_scope { order(:name) }
  scope :at, -> (store) { where(store: store) }

  #---
  validates :name, presence: true, uniqueness: {scope: :store}

  #---
  def to_s
    name
  end
end
