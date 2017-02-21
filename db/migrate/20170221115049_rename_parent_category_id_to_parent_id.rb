class RenameParentCategoryIdToParentId < ActiveRecord::Migration
  def up
    remove_index :categories, :parent_category_id
    rename_column :categories, :parent_category_id, :parent_id
    add_index :categories, :parent_id
  end

  def down
    remove_index :categories, :parent_id
    rename_column :categories, :parent_id, :parent_category_id
    add_index :categories, :parent_category_id
  end
end
