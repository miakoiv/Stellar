class AddOrderItemsCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_items_count, :integer, after: :store_id
  end
end
