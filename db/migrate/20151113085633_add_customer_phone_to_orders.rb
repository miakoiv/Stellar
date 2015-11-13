class AddCustomerPhoneToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_phone, :string, after: :customer_email
  end
end
