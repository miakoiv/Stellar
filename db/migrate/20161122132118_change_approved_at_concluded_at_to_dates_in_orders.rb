class ChangeApprovedAtConcludedAtToDatesInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :approved_at, :date
    change_column :orders, :concluded_at, :date
  end
end
