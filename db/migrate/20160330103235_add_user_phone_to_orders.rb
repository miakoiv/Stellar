class AddUserPhoneToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :user_phone, :string, after: :user_email
  end
end
