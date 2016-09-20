#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  monetize :value_cents, allow_nil: true
  monetize :total_value_cents

  #---
  belongs_to :inventory
  belongs_to :product

  has_many :inventory_entries, dependent: :destroy
  accepts_nested_attributes_for :inventory_entries, limit: 1

  default_scope { order(:created_at) }
  scope :active, -> { where('on_hand > 0') }

  #---
  validates :inventory_id, presence: true
  validates :product_id, presence: true
  validates :code, presence: true
  validates_associated :inventory_entries

  #---
  after_save :update_amount_and_value!

  #---
  def total_value_cents
    return 0 if on_hand.nil? || value_cents.nil? || on_hand < 0
    on_hand * value_cents
  end

  # Reduces stock from this inventory item.
  def destock!(amount, source = nil, recorded_at = nil)
    recorded_at ||= Date.today
    inventory_entries.create(
      recorded_at: recorded_at,
      source: source,
      amount: -amount,
      value: value
    )
    update_amount_and_value!
  end

  def title
    inventory.name
  end

  def appearance
    on_hand > 0 ? 'success' : 'warning'
  end

  private
    # After save, update the inventory count and value from the entries.
    def update_amount_and_value!
      entries = inventory_entries(true)
      total_amount = entries.sum(:amount)
      weighted_total_cents = entries.map { |e| e.amount * e.value_cents }.sum

      update_columns(
        on_hand: total_amount,
        value_cents: total_amount == 0 ? 0 : weighted_total_cents / total_amount
      )
    end
end
