class RemoveAddressesFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :has_billing_address, :boolean, null: false, default: false, after: :contact_phone
    remove_column :orders, :billing_street, :string, after: :has_billing_address
    remove_column :orders, :billing_postalcode, :string, after: :billing_street
    remove_column :orders, :billing_city, :string, after: :billing_postalcode
    remove_column :orders, :billing_country_code, :string, limit: 2, after: :billing_city
    remove_column :orders, :shipping_street, :string, after: :billing_country_code
    remove_column :orders, :shipping_postalcode, :string, after: :shipping_street
    remove_column :orders, :shipping_city, :string, after: :shipping_postalcode
    remove_column :orders, :shipping_country_code, :string, limit: 2, after: :shipping_city
  end
end
