class ReindexGroupsUsersJoinTable < ActiveRecord::Migration
  def change
    remove_index :groups_users, :group_id
    remove_index :groups_users, :user_id
    add_index :groups_users, [:group_id, :user_id], unique: true
  end
end
