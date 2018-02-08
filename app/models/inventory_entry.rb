#encoding: utf-8

class InventoryEntry < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  # Values are for each, total value is added to inventory item value.
  monetize :value_cents
  monetize :total_value_cents, disable_validation: true

  belongs_to :inventory_item, touch: true

  # The source can be any object that's responsible for the existence
  # of this particular entry.
  belongs_to :source, polymorphic: true

  default_scope { order(recorded_at: :desc, created_at: :desc) }

  scope :with_serial_number, -> { where.not(serial_number: nil) }

  #---
  validates :recorded_at, presence: true, on: :create
  validates :on_hand, numericality: {only_integer: true}
  validates :reserved, numericality: {only_integer: true}
  validates :pending, numericality: {only_integer: true}

  #---
  # Availability takes reserved amounts out.
  def available
    on_hand - reserved
  end

  # Total value is calculated from amount on hand.
  def total_value_cents
    on_hand * value_cents
  end
end
