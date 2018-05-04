class AddHasPickupPointsToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :has_pickup_points, :boolean, null: false, default: false, after: :shipping_gateway
  end
end
