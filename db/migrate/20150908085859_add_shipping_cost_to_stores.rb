class AddShippingCostToStores < ActiveRecord::Migration
  def change
    add_column :stores, :shipping_cost_product_id, :integer, after: :admit_guests
    add_column :stores, :free_shipping_at, :decimal, precision: 8, scale: 2,
      after: :shipping_cost_product_id
  end
end
