class AddDifferenceAndAdjustmentToInventoryCheckItems < ActiveRecord::Migration
  def change
    add_column :inventory_check_items, :difference, :integer, after: :current
    add_column :inventory_check_items, :adjustment, :integer, after: :difference
  end
end
