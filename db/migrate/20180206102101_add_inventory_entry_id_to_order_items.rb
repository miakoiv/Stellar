class AddInventoryEntryIdToOrderItems < ActiveRecord::Migration
  def change
    add_reference :order_items, :inventory_entry, index: true, after: :inventory_item_id
  end
end
