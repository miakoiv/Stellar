#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  monetize :value_cents, allow_nil: true
  monetize :total_value_cents, disable_validation: true

  #---
  belongs_to :inventory
  belongs_to :product, touch: true

  has_many :inventory_entries, dependent: :destroy
  accepts_nested_attributes_for :inventory_entries, limit: 1

  default_scope { order(:created_at) }

  # Inventory items are considered online if they have stock available.
  scope :online, -> { where('on_hand - reserved > 0') }

  #---
  validates :inventory_id, presence: true
  validates :product_id, presence: true
  validates :code, presence: true
  validates_associated :inventory_entries

  #---
  after_save :update_counts_and_value!

  #---
  def available
    on_hand - reserved
  end

  def total_value_cents
    [0, on_hand].max * (value_cents || 0)
  end

  # Reduces on hand stock from this inventory item.
  def destock!(amount, source = nil, recorded_at = nil)
    recorded_at ||= Date.today
    inventory_entries.create(
      recorded_at: recorded_at,
      source: source,
      on_hand: -amount,
      reserved: 0,
      pending: 0,
      value: value
    )
    update_counts_and_value!
  end

  def title
    inventory.name
  end

  private
    # After save, update the inventory counts and value from the entries.
    # Value is calculated from on hand inventory, using a weighted average
    # of values given in the entries.
    def update_counts_and_value!
      entries = inventory_entries(true)
      total_on_hand = entries.sum(:on_hand)
      total_reserved = entries.sum(:reserved)
      total_pending = entries.sum(:pending)
      weighted_total_cents = entries.map { |e| e.on_hand * e.value_cents }.sum

      update_columns(
        on_hand: total_on_hand,
        reserved: total_reserved,
        pending: total_pending,
        value_cents: total_on_hand == 0 ? 0 : weighted_total_cents / total_on_hand
      )
    end
end
