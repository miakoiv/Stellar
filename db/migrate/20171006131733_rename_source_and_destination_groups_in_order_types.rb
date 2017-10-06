class RenameSourceAndDestinationGroupsInOrderTypes < ActiveRecord::Migration
  def change
    rename_column :order_types, :source_group, :source_level
    rename_column :order_types, :destination_group, :destination_level
  end
end
