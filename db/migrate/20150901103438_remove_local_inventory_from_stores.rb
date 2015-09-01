class RemoveLocalInventoryFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :local_inventory, :boolean
  end
end
