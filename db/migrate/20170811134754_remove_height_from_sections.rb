class RemoveHeightFromSections < ActiveRecord::Migration
  def change
    remove_column :sections, :height, :integer, after: :layout
  end
end
