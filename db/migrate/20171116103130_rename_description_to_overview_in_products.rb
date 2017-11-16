class RenameDescriptionToOverviewInProducts < ActiveRecord::Migration
  def change
    rename_column :products, :description, :overview
  end
end
