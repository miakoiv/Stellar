class RemoveAddressesFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :billing_street, :string, after: :phone
    remove_column :users, :billing_postalcode, :string, after: :billing_street
    remove_column :users, :billing_city, :string, after: :billing_postalcode
    remove_column :users, :billing_country_code, :string, limit: 2, after: :billing_city
    remove_column :users, :shipping_street, :string, after: :billing_country_code
    remove_column :users, :shipping_postalcode, :string, after: :shipping_street
    remove_column :users, :shipping_city, :string, after: :shipping_postalcode
    remove_column :users, :shipping_country_code, :string, limit: 2, after: :shipping_city
  end
end
