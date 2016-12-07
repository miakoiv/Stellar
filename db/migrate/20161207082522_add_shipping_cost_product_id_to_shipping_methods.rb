class AddShippingCostProductIdToShippingMethods < ActiveRecord::Migration
  def change
    add_reference :shipping_methods, :shipping_cost_product, after: :description
  end
end
