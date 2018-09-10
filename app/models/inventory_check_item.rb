#encoding: utf-8

class InventoryCheckItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :inventory_check
  delegate :inventory, to: :inventory_check

  # Inventory check items have a product association and
  # attributes for lot code, expiration, and current amount,
  # but may be associated with a matching inventory item.
  belongs_to :inventory_item
  delegate :on_hand, to: :inventory_item

  belongs_to :product, required: true
  delegate :real?, to: :product
  delegate :code, :customer_code, :title, :subtitle, to: :product, prefix: true

  default_scope { order(updated_at: :desc) }
  scope :mismatching, -> { joins('LEFT OUTER JOIN inventory_items ON inventory_items.id = inventory_item_id').where('inventory_items.id IS NULL OR inventory_items.on_hand != current') }

  #---
  validates :lot_code, presence: true
  validates :current, numericality: {
    integer_only: true,
    greater_than_or_equal_to: 0
  }

  attr_accessor :serial
  before_validation :concatenate_lot_code
  after_validation :assign_inventory_item, on: :create

  #---
  # We are stocked if a matching inventory item exists.
  def stocked?
    inventory_item.present?
  end

  def matching?
    stocked? && current == on_hand
  end

  def appearance
    return 'danger text-danger' if !stocked?
    matching? || 'warning text-warning'
  end

  # Amount needed to fix existing inventory item,
  # or to initialize a new one if none exist.
  def amount
    stocked? ? current - on_hand : current
  end

  def apply_adjustment!
  end

  def icon
    return nil if matching?
    return 'exclamation-circle' if !stocked?
    current > on_hand ? 'plus' : 'minus'
  end

  def customer_code=(val)
    self.product = Product.find_by(customer_code: val)
  end

  def to_s
    "%d⨉ %s (%s)" % [current, product, lot_code]
  end

  private
    # Lot code and serial are joined by hyphen, either one appearing alone
    # is used as the lot code.
    def concatenate_lot_code
      self[:lot_code] = [lot_code, serial].map(&:presence).compact.join('-')
    end

    # The matching inventory item can be found by product and lot code
    # from the inventory where the check is performed.
    def assign_inventory_item
      self.inventory_item = inventory.item_by_product_and_code(product, lot_code)
    end
end
