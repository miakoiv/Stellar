class AddUnlimitedToInventoryItems < ActiveRecord::Migration[5.2]
  def change
    add_column :inventory_items, :unlimited, :boolean, null: false, default: false, after: :pending
  end
end
