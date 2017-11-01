class RemoveStoreIdFromUsers < ActiveRecord::Migration
  def up
    remove_index :users, [:store_id, :email]
    remove_column :users, :store_id
    add_index :users, :email, unique: true
  end

  def down
    remove_index :users, :email
    add_column :users, :store_id, :integer, null: false, first: true
    add_index :users, [:store_id, :email], unique: true
  end
end
