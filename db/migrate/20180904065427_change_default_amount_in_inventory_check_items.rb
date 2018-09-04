class ChangeDefaultAmountInInventoryCheckItems < ActiveRecord::Migration
  def change
    change_column_default :inventory_check_items, :amount, 0
  end
end
