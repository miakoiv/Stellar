class ReindexUsersByEmailAndStoreId < ActiveRecord::Migration
  def change
    remove_index :users, :email
    add_index :users, [:store_id, :email], unique: true
  end
end
