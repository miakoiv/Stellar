class AddConcludedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :concluded_at, :datetime, after: :approved_at
  end
end
