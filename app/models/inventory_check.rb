#encoding: utf-8

class InventoryCheck < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable

  #---
  belongs_to :store
  belongs_to :inventory, required: true
  has_many :inventory_check_items, dependent: :destroy

  default_scope { order(created_at: :desc) }

  scope :complete, -> { where.not(completed_at: nil) }

  #---
  def complete?
    completed_at.present?
  end

  def incomplete?
    !complete?
  end

  def complete!
    update completed_at: Time.current
  end

  def appearance
    complete? || 'warning text-warning'
  end

  def icon
    complete? || 'cog'
  end

  def to_s
    note
  end
end
