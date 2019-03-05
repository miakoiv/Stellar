class AddAwesomeNestedSetToGroups < ActiveRecord::Migration[5.2]
  def up
    add_reference :groups, :parent, type: :integer, index: true, after: :store_id
    add_column :groups, :lft, :integer, index: true, after: :parent_id
    add_column :groups, :rgt, :integer, index: true, after: :lft
    add_column :groups, :depth, :integer, null: false, default: 0, after: :rgt
    add_column :groups, :children_count, :integer, null: false, default: 0, after: :depth

    Group.reset_column_information
    Group.rebuild!(false)
  end

  def down
    remove_reference :groups, :parent
    remove_column :groups, :lft
    remove_column :groups, :rgt
    remove_column :groups, :depth
    remove_column :groups, :children_count
  end
end
