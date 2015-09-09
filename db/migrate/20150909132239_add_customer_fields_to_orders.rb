class AddCustomerFieldsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_name, :string, after: :approved_at
    add_column :orders, :customer_email, :string, after: :customer_name
  end
end
