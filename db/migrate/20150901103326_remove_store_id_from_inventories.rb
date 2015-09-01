class RemoveStoreIdFromInventories < ActiveRecord::Migration
  def change
    remove_column :inventories, :store_id, :integer
  end
end
