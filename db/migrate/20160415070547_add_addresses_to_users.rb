class AddAddressesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_address, :string, after: :phone
    add_column :users, :billing_postalcode, :string, after: :billing_address
    add_column :users, :billing_city, :string, after: :billing_postalcode
    add_column :users, :billing_country, :string, default: 'FI', after: :billing_city
    add_column :users, :shipping_address, :string, after: :billing_country
    add_column :users, :shipping_postalcode, :string, after: :shipping_address
    add_column :users, :shipping_city, :string, after: :shipping_postalcode
    add_column :users, :shipping_country, :string, default: 'FI', after: :shipping_city
  end
end
