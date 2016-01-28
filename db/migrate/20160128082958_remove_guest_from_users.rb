class RemoveGuestFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :guest, :boolean, null: false, default: false
  end
end
