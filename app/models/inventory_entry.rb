#encoding: utf-8

class InventoryEntry < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  # Values are for each, total value is added to inventory item value.
  monetize :value_cents
  monetize :total_value_cents

  belongs_to :inventory_item

  # The source can be any object that's responsible for the existence
  # of this particular entry.
  belongs_to :source, polymorphic: true

  default_scope { order(recorded_at: :desc, created_at: :desc) }

  #---
  validates :recorded_at, presence: true
  validates :amount, numericality: {only_integer: true}

  #---
  def total_value_cents
    amount * value_cents
  end
end
