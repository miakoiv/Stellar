class ChangeCountriesToCountryCodes < ActiveRecord::Migration
  def up
    change_column :orders, :billing_country, :string, limit: 2
    rename_column :orders, :billing_country, :billing_country_code

    change_column :orders, :shipping_country, :string, limit: 2
    rename_column :orders, :shipping_country, :shipping_country_code

    change_column :users, :billing_country, :string, limit: 2
    rename_column :users, :billing_country, :billing_country_code

    change_column :users, :shipping_country, :string, limit: 2
    rename_column :users, :shipping_country, :shipping_country_code
  end

  def down
    rename_column :orders, :billing_country_code, :billing_country
    change_column :orders, :billing_country, :string, limit: 255

    rename_column :orders, :shipping_country_code, :shipping_country
    change_column :orders, :shipping_country, :string, limit: 255

    rename_column :users, :billing_country_code, :billing_country
    change_column :users, :billing_country, :string, limit: 255

    rename_column :users, :shipping_country_code, :shipping_country
    change_column :users, :shipping_country, :string, limit: 255
  end
end
