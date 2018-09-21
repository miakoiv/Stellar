#encoding: utf-8

class InventoryCheck < ActiveRecord::Base

  resourcify
  include Authority::Abilities
  include Trackable

  #---
  belongs_to :store
  belongs_to :inventory, required: true

  # This association has an extension to merge a new inventory check item
  # with an existing similar item, because the item needs to be built first
  # to include a product id needed for find_or_initialize_by
  has_many :inventory_check_items, dependent: :destroy do
    def merge(new_item)
      find_or_initialize_by(
        product: new_item.product,
        lot_code: new_item.lot_code
      ).tap do |item|
        item.current += new_item.current
      end
    end
  end

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
