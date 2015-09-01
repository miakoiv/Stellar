class CreateStoreInventoryJoinTable < ActiveRecord::Migration
  def change
    create_join_table :stores, :inventories do |t|
      # t.index [:store_id, :inventory_id]
      t.index [:inventory_id, :store_id], unique: true
    end
  end
end
