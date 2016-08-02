#encoding: utf-8

class Portal < ActiveRecord::Base

  store :settings, accessors: [
    :locale,
    :theme
  ], coder: JSON

  resourcify
  include Authority::Abilities
  include Imageable

  #---
  # Portals combine any number of stores together, while
  # stores may belong to multiple portals.
  has_and_belongs_to_many :stores

  # Departments act like virtual categories for portals, coalescing
  # products from multiple categories across different stores
  # into a single view.
  has_many :departments, dependent: :destroy

  #---
  validates :name, presence: true
  validates :domain, presence: true, uniqueness: true

  #---
  def description
    name
  end

  def to_s
    name
  end
end
