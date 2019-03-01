#
# Transfer items record what is transferred by product and lot code.
#
class TransferItem < ApplicationRecord

  resourcify
  include Authority::Abilities

  #---
  belongs_to :transfer
  delegate :complete?, :source, :destination, to: :transfer

  # Transfer items may reference an order item they were created for.
  belongs_to :order_item, optional: true

  belongs_to :product
  delegate :real?, to: :product
  delegate :code, :customer_code, :title, :subtitle, to: :product, prefix: true

  default_scope { order(updated_at: :desc) }

  #---
  validates :lot_code, presence: true
  validates :amount, numericality: {
    integer_only: true,
    greater_than_or_equal_to: 1
  }

  attr_accessor :serial
  after_initialize :lot_code_from_serial

  #---
  # The source inventory item associated with this tranfer item
  # is found by product and lot code from the source inventory.
  def source_item
    source.item_by_product_and_code(product, lot_code)
  end

  # Finds the choices for source item by transferred product.
  def source_item_choices
    source.items_by_product(product)
  end

  # Transfer items are feasible if there's enough stock
  # or the product does not require stock tracking.
  def feasible?
    return true if source.nil? || !product.tracked_stock?
    inventory_item = source_item
    inventory_item.present? && inventory_item.available >= amount
  end

  def appearance
    complete? || feasible? || 'danger text-danger'
  end

  def customer_code=(val)
    self.product = Product.find_by(customer_code: val)
  end

  def to_s
    "%d⨉ %s (%s)" % [amount, product, lot_code]
  end

  private
    # Serial is used as lot code on products that have no lot code.
    def lot_code_from_serial
      if lot_code.blank? && serial.present?
        self[:lot_code] = serial
      end
    end
end
