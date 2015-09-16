class RemoveSettingFieldsFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :menu_title, :string
    remove_column :stores, :theme, :string
    remove_column :stores, :locale, :string
    remove_column :stores, :b2b_sales, :boolean
    remove_column :stores, :admit_guests, :boolean
    remove_column :stores, :shipping_cost_product_id, :integer
    remove_column :stores, :free_shipping_at, :decimal
    remove_column :stores, :tracking_code, :string
  end
end
