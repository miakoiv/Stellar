#encoding: utf-8

class InventoryItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  monetize :value_cents, allow_nil: true
  monetize :total_value_cents, disable_validation: true

  #---
  belongs_to :inventory, required: true
  belongs_to :product, touch: true
  delegate :real?, to: :product
  delegate :code, :customer_code, :title, :subtitle, to: :product, prefix: true

  has_many :inventory_entries, dependent: :destroy
  accepts_nested_attributes_for :inventory_entries, limit: 1

  # The order is by expiration first with nil expiration sorted last,
  # creation date second.
  default_scope { order('expires_at IS NULL', :expires_at, :created_at) }

  # Inventory items are considered online if they have stock available.
  scope :online, -> { where('on_hand - reserved > 0') }

  scope :in, -> (inventory) { where(inventory: inventory) }
  scope :for, -> (product) { where(product: product) }

  #---
  validates :product_id, presence: true
  validates :code, presence: true
  validates_associated :inventory_entries

  #---
  after_save :update_counts_and_value!
  after_touch :update_counts_and_value!

  #---
  def self.by_product
    select(
      'inventory_items.product_id,
      SUM(on_hand) AS total_on_hand,
      SUM(reserved) AS total_reserved,
      SUM(pending) AS total_pending,
      products.*'
    ).group(:product_id)
  end

  # Options for a search form.
  def self.online_options
    [
      [human_attribute_value(:status, :online), true],
      [human_attribute_value(:status, :all), false]
    ]
  end

  #---
  def available
    on_hand - reserved
  end

  def total_value_cents
    [0, on_hand].max * (value_cents || 0)
  end

  def title
    inventory.name
  end

  def to_s
    code
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
