#encoding: utf-8

class Transfer < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :store
  belongs_to :source, class_name: 'Inventory'
  belongs_to :destination, class_name: 'Inventory'

  has_many :transfer_items, dependent: :destroy

  default_scope { order(created_at: :desc) }

  scope :complete, -> { where.not(completed_at: nil) }

  #---
  validates :source, presence: true
  validates :destination, presence: true
  validates :destination_id, exclusion: {
    in: -> (transfer) { [transfer.source_id] },
    message: :same_as_source
  }

  #---
  def complete?
    completed_at.present?
  end

  def incomplete?
    !complete?
  end

  def appearance
    incomplete? && 'warning text-warning'
  end

  def icon
    incomplete? && 'cog'
  end

  def to_s
    note
  end
end
