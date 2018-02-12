# Adds a customer association and updates existing orders
# to have their user as the customer, which is an acceptable
# compromise at this point.
class AddCustomerIdToOrders < ActiveRecord::Migration
  def up
    add_reference :orders, :customer, null: false, index: true, after: :user_id
    execute <<-SQL
      UPDATE orders SET customer_id = user_id
    SQL
  end

  def down
    remove_reference :orders, :customer
  end
end
