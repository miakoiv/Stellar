class AddEnableGatewayToInventories < ActiveRecord::Migration[5.2]
  def change
    add_column :inventories, :enable_gateway, :boolean, null: false, default: false, after: :inventory_code
  end
end
