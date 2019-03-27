class RenameAddressesForOrdersAndUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :shipping_address, :shipping_street
    rename_column :orders, :billing_address, :billing_street
    rename_column :users, :shipping_address, :shipping_street
    rename_column :users, :billing_address, :billing_street
  end
end
