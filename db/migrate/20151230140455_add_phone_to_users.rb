class AddPhoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string, after: :email
  end
end
