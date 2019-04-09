class RemoveCustomerRefFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_reference :orders, :customer, type: :integer, null: false, index: true, after: :user_id
  end
end
