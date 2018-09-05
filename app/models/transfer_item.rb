#encoding: utf-8
#
# Transfer items record what is transferred by product and lot code.
#
class TransferItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :transfer
  delegate :complete?, :source, :destination, to: :transfer

  # Transfer items may reference an order item they were created for.
  belongs_to :order_item

  belongs_to :product, required: true
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
  before_validation :concatenate_lot_code

  #---
  # The source inventory item associated with this tranfer item
  # is found by product and lot code from the source inventory.
  def source_item
    source.item_by_product_and_code(product, lot_code)
  end

  # Transfer items are feasible if there's enough stock.
  def feasible?
    return true if source.nil?
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
    # Lot code and serial are joined by hyphen, either one appearing alone
    # is used as the lot code.
    def concatenate_lot_code
      self[:lot_code] = [lot_code, serial].map(&:presence).compact.join('-')
    end
end
