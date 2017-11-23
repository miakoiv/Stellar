class AddPriorityToInventories < ActiveRecord::Migration
  def change
    add_column :inventories, :priority, :integer, null: false, default: 0, after: :inventory_code
  end
end
