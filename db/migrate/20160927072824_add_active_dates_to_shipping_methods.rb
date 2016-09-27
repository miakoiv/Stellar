class AddActiveDatesToShippingMethods < ActiveRecord::Migration
  def change
    add_column :shipping_methods, :enabled_at, :date, after: :shipping_gateway
    add_column :shipping_methods, :disabled_at, :date, after: :enabled_at
  end
end
