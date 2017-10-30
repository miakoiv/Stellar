class RemoveSourceLevelAndDestinationLevelFromOrderTypes < ActiveRecord::Migration
  def change
    remove_column :order_types, :source_level, :integer, after: :label
    remove_column :order_types, :destination_level, :integer, after: :source_level
  end
end
