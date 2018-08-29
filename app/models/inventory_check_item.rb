#encoding: utf-8

class InventoryCheckItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :inventory_check
  delegate :inventory, to: :inventory_check

  # Inventory check items have a product association and
  # attributes for lot code, expiration, and on hand amount,
  # but may be associated with a matching inventory item.
  belongs_to :inventory_item

  belongs_to :product
  delegate :real?, to: :product
  delegate :code, :customer_code, :title, :subtitle, to: :product, prefix: true

  default_scope { order(updated_at: :desc) }

  #---
  validates :product_id, presence: true
  validates :lot_code, presence: true
  validates :amount, numericality: {
    integer_only: true,
    greater_than_or_equal_to: 1
  }

  attr_accessor :serial
  before_validation :concatenate_lot_code
  after_validation :assign_inventory_item, on: :create

  #---
  def appearance
  end

  def customer_code=(val)
    self.product = Product.find_by(customer_code: val)
  end

  def to_s
    "%d⨉ %s (%s)" % [amount, product, lot_code]
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
