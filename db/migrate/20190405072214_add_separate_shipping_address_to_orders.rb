class AddSeparateShippingAddressToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :separate_shipping_address, :boolean, null: false, default: false, after: :shipping_address_id
  end
end
