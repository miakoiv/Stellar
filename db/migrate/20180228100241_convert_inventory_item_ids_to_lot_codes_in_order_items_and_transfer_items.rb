# This migration converts existing inventory item references
# to lot codes in both order items and transfer items, since
# inventory item references are not workable in cases where
# for example a transfer is performed from nil source inventory,
# so transfer items can't reference an existing inventory item.
#
class ConvertInventoryItemIdsToLotCodesInOrderItemsAndTransferItems < ActiveRecord::Migration
  def change
    add_column :order_items, :lot_code, :string, after: :product_id
    add_column :transfer_items, :lot_code, :string, after: :product_id
    remove_reference :order_items, :inventory_item, index: true, after: :product_id
    remove_reference :transfer_items, :inventory_item, index: true, after: :product_id
  end
end
