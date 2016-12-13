class AddFreeShippingFromToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :free_shipping_from_cents, :integer, after: :shipping_cost_product_id
  end
end
