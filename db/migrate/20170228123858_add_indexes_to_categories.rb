class AddIndexesToCategories < ActiveRecord::Migration
  def change
    add_index :categories, :lft
    add_index :categories, :rgt
    add_index :categories, :depth
  end
end
