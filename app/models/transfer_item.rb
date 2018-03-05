#encoding: utf-8
#
# Transfer items record what is transferred by product and lot code.
#
class TransferItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :transfer
  delegate :source, :destination, to: :transfer

  belongs_to :product

  #---
  validates :product_id, presence: true
  validates :lot_code, presence: true, unless: :shipment?
  validates :amount, numericality: {
    integer_only: true,
    greater_than_or_equal_to: 1
  }


  #---
  # The source inventory item associated with this tranfer item
  # is found by product and lot code from the source inventory.
  def source_item
    source.inventory_items.find_by(
      product: product,
      code: lot_code
    )
  end

  # Transfer items are feasible if there's enough stock.
  def feasible?
    source_item.nil? || source_item.available >= amount
  end

  # Checks if this item is part of a transfer associated with a shipment,
  # allowing lot code to be omitted, and automatically resolved to pick
  # the oldest available lot when the transfer is being completed.
  def shipment?
    transfer.shipment.present?
  end

  def appearance
    feasible? || 'danger text-danger'
  end
end
