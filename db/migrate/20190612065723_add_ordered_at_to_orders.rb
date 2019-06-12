class AddOrderedAtToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :ordered_at, :date, after: :completed_at
  end
end
