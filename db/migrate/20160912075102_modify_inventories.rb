class ModifyInventories < ActiveRecord::Migration
  def up
    remove_column :inventories, :purpose
    add_column :inventories, :inventory_code, :string, after: :name
  end

  def down
    add_column :inventories, :purpose, :integer, null: false, default: 0, after: :store_id
    remove_column :inventories, :inventory_code
  end
end
