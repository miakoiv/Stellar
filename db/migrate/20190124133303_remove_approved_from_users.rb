class RemoveApprovedFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :approved, :boolean, null: false, default: false, index: true, after: :last_sign_in_ip
  end
end
