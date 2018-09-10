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

  def conclude!
    update concluded_at: Time.current
  end

  def concluded?
    concluded_at.present?
  end

  def appearance
    return nil if concluded?
    complete? ? 'info text-info' : 'warning text-warning'
  end

  def life_pro_tip
    return [:info, '.concluded'] if concluded?
    return [:warning, '.complete'] if complete?
    [:danger, '.incomplete']
  end

  def icon
    return nil if concluded?
    complete? ? 'refresh' : 'cog'
  end

  def to_s
    note
  end
end
