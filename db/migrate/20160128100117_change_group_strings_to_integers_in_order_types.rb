class ChangeGroupStringsToIntegersInOrderTypes < ActiveRecord::Migration
  def change
    change_column :order_types, :source_group, :integer
    change_column :order_types, :destination_group, :integer
  end
end
