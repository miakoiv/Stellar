class AddHomeDeliveryToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :home_delivery, :boolean, null: false, default: false, after: :has_pickup_points
  end
end
