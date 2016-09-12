class RemoveStoreIdFromInventoryItems < ActiveRecord::Migration
  def up
    remove_column :inventory_items, :store_id
  end

  def down
    add_reference :inventory_items, :store, index: true, foreign_key: false, after: :inventory_id
  end
end
