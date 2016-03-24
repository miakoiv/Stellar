class AddInstallationAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :installation_at, :date, after: :shipping_at
  end
end
