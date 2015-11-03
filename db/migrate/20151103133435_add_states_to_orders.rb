class AddStatesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :checkout_state, :string, after: :id
    add_column :orders, :state, :string, after: :checkout_state
    rename_column :orders, :ordered_at, :completed_at
  end
end
