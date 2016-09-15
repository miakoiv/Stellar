class ModifyInventoryItems < ActiveRecord::Migration
  def up
    add_column :inventory_items, :code, :string, null: false, after: :product_id
    remove_column :inventory_items, :shelf
  end

  def down
    add_column :inventory_items, :shelf, :string, after: :product_id
    remove_column :inventory_items, :code
  end
end
