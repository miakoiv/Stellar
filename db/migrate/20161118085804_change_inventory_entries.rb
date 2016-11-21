class ChangeInventoryEntries < ActiveRecord::Migration
  def up
    rename_column :inventory_entries, :amount, :on_hand
    add_column :inventory_entries, :reserved, :integer, null: false, after: :on_hand
    add_column :inventory_entries, :pending, :integer, null: false, after: :reserved
  end

  def down
    remove_column :inventory_entries, :pending
    remove_column :inventory_entries, :reserved
    rename_column :inventory_entries, :on_hand, :amount
  end
end
