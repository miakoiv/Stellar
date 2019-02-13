class Policy < ApplicationRecord

  include Authority::Abilities
  include Trackable

  #---
  belongs_to :store
  belongs_to :accepted_by, class_name: 'User'

  default_scope { order(created_at: :asc) }
  scope :pending, -> { where(mandatory: true, accepted_at: nil) }

  #---
  validates :title, presence: true

  #---
  attr_accessor :accepted

  #---
  def pending?
    mandatory? && !accepted?
  end

  def accepted?
    accepted_at.present?
  end

  def to_s
    title
  end
end
