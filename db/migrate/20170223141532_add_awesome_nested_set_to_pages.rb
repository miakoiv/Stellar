class AddAwesomeNestedSetToPages < ActiveRecord::Migration
  def up
    remove_index :pages, :parent_page_id
    rename_column :pages, :parent_page_id, :parent_id
    add_column :pages, :lft, :integer, index: true, after: :parent_id
    add_column :pages, :rgt, :integer, index: true, after: :lft
    add_column :pages, :depth, :integer, null: false, default: 0, after: :rgt
    add_column :pages, :children_count, :integer, null: false, default: 0, after: :depth
    remove_column :pages, :priority
    add_index :pages, :parent_id

    Page.rebuild!(false)
  end

  def down
    remove_column :pages, :lft
    remove_column :pages, :rgt
    remove_column :pages, :depth
    remove_column :pages, :children_count
    add_column :pages, :priority, :integer, after: :wysiwyg
    remove_index :pages, :parent_id
    rename_column :pages, :parent_id, :parent_page_id
    add_index :pages, :parent_page_id
  end
end
