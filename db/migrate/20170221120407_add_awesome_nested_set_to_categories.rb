class AddAwesomeNestedSetToCategories < ActiveRecord::Migration
  def up
    add_column :categories, :lft, :integer, index: true, after: :parent_id
    add_column :categories, :rgt, :integer, index: true, after: :lft
    add_column :categories, :depth, :integer, null: false, default: 0, after: :rgt
    add_column :categories, :children_count, :integer, null: false, default: 0, after: :depth
    remove_column :categories, :priority

    Category.rebuild!(false)
  end

  def down
    remove_column :categories, :lft
    remove_column :categories, :rgt
    remove_column :categories, :depth
    remove_column :categories, :children_count
    add_column :categories, :priority, :integer, after: :product_scope
  end
end
