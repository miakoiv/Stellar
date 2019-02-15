class ChangeOrderItemsCountDefaultInOrders < ActiveRecord::Migration[5.0]
  def change
    change_column_null :orders, :order_items_count, false, 0
    change_column_default :orders, :order_items_count, from: nil, to: 0
  end
end
