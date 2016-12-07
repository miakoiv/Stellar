class AddDeliveryTimeToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :delivery_time, :integer, after: :shipping_gateway
  end
end
