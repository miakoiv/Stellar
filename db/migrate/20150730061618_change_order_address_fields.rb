class ChangeOrderAddressFields < ActiveRecord::Migration
  def change
    change_column :orders, :billing_address, :string
    add_column :orders, :billing_postalcode, :string, after: :billing_address
    add_column :orders, :billing_city, :string, after: :billing_postalcode
    add_column :orders, :billing_country, :string, null: :false, default: 'FI', after: :billing_city
    change_column :orders, :shipping_address, :string
    add_column :orders, :shipping_postalcode, :string, after: :shipping_address
    add_column :orders, :shipping_city, :string, after: :shipping_postalcode
    add_column :orders, :shipping_country, :string, null: :false, default: 'FI', after: :shipping_city
  end
end
