class ChangeRoleDefsIntoGroupsInOrderTypes < ActiveRecord::Migration
  def change
    remove_index :order_types, column: :source_role_id
    remove_index :order_types, column: :destination_role_id
    remove_columns :order_types, :source_role_id, :destination_role_id
    add_column :order_types, :source_group, :string, after: :name
    add_column :order_types, :destination_group, :string, after: :source_group
  end
end
