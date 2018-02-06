class AddSerialNumberToInventoryEntries < ActiveRecord::Migration
  def change
    add_column :inventory_entries, :serial_number, :string, after: :inventory_item_id
  end
end
