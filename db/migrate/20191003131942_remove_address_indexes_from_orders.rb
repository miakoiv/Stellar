class RemoveAddressIndexesFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_index :orders, name: 'index_orders_on_billing_address_id'
    remove_index :orders, name: 'index_orders_on_shipping_address_id'
  end
end
