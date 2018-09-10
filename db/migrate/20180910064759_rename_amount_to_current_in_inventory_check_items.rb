class RenameAmountToCurrentInInventoryCheckItems < ActiveRecord::Migration
  def change
    rename_column :inventory_check_items, :amount, :current
  end
end
