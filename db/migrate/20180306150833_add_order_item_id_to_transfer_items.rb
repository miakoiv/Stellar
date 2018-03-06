class AddOrderItemIdToTransferItems < ActiveRecord::Migration
  def change
    add_reference :transfer_items, :order_item, index: true, after: :transfer_id
  end
end
