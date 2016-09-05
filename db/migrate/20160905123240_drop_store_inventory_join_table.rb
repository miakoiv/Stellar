class DropStoreInventoryJoinTable < ActiveRecord::Migration
  def up
    drop_table :inventories_stores
  end

  def down
    create_join_table :stores, :inventories do |t|
      # t.index [:store_id, :inventory_id]
      t.index [:inventory_id, :store_id], unique: true
    end
  end
end
