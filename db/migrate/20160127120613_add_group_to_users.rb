class AddGroupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :group, :integer, null: false, default: 0, after: :store_id
  end
end
