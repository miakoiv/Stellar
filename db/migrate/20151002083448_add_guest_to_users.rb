class AddGuestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guest, :boolean, null: false, default: false, after: :store_id
  end
end
