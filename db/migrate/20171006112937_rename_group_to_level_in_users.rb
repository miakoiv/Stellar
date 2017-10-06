class RenameGroupToLevelInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :group, :level
  end
end
