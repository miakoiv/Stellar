class RemoveShapeFromSections < ActiveRecord::Migration[5.2]
  def change
    remove_column :sections, :shape, :string, after: :viewport
  end
end
