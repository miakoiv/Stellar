class RemoveLevelFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :level, :integer, null: false, after: :store_id
  end
end
