class AddInventoryItemIdToOrderItems < ActiveRecord::Migration
  def change
    add_reference :order_items, :inventory_item, index: true, after: :product_id
  end
end
