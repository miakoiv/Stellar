class InventoryCheckItem < ApplicationRecord

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

  default_scope { order('updated_at DESC, id DESC') }
  scope :mismatching, -> { where.not(difference: 0) }
  scope :pending, -> { where(adjustment: nil) }

  #---
  validates :lot_code, presence: true
  validates :current, numericality: {
    integer_only: true,
    greater_than_or_equal_to: 0
  }

  attr_accessor :serial
  after_initialize :lot_code_from_serial
  after_validation :assign_inventory_item, on: :create
  after_validation :calculate_difference

  #---
  def final?
    adjustment.present?
  end

  def pending?
    !final?
  end

  # We are stocked if a matching inventory item exists.
  def stocked?
    inventory_item.present?
  end

  def matching?
    difference == 0
  end

  def appearance
    return nil if final?
    return 'danger text-danger' if !stocked?
    matching? || 'warning text-warning'
  end

  # Amount needed to restock the inventory is the difference.
  def amount
    difference
  end

  # Approves the required adjustment to inventory
  # by restocking with this item.
  def approve!
    inventory.restock!(self, Time.current, inventory_check)
    update!(adjustment: difference)
  end

  # Discards the item by setting its adjustment to zero.
  def discard!
    update!(adjustment: 0)
  end

  def customer_code=(val)
    self.product = Product.find_by(customer_code: val)
  end

  def to_s
    "%d⨉ %s (%s)" % [current, product, lot_code]
  end

  private
    # Serial is used as lot code on products that have no lot code.
    def lot_code_from_serial
      if lot_code.blank? && serial.present?
        self[:lot_code] = serial
      end
      true
    end

    # Existing, matching inventory item is associated after validation,
    # if the association is not established yet.
    def assign_inventory_item
      self.inventory_item ||= inventory.item_by_product_and_code(product, lot_code)
      self
    end

    # The difference between current and on hand amounts
    # is calculated after save.
    def calculate_difference
      unless final?
        self.difference = stocked? ? current - on_hand : current
      end
      self
    end
end
