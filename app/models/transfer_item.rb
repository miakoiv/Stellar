#encoding: utf-8
#
# Transfer items record what is transferred by product and inventory item.
#
class TransferItem < ActiveRecord::Base

  resourcify
  include Authority::Abilities

  #---
  belongs_to :transfer
  belongs_to :product
  belongs_to :inventory_item

  #---
  validates :product_id, presence: true
  validates :inventory_item_id, presence: true, uniqueness: {scope: :transfer_id}
  validates :amount, numericality: {
    integer_only: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: -> (transfer_item) {
      transfer_item.inventory_item.available
    }
  }
end
