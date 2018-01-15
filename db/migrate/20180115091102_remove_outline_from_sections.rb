class RemoveOutlineFromSections < ActiveRecord::Migration
  def change
    remove_column :sections, :outline, :integer, null: false, default: 1, after: :width
  end
end
