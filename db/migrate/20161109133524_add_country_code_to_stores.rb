class AddCountryCodeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :country_code, :string, limit: 2, null: false, after: :slug
  end
end
