class ModifyInventoryItemAmounts < ActiveRecord::Migration
  def change
    rename_column :inventory_items, :amount, :on_hand
    add_column :inventory_items, :reserved, :integer, after: :on_hand
    add_column :inventory_items, :pending, :integer, after: :reserved
  end
end
