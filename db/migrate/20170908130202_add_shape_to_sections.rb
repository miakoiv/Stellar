class AddShapeToSections < ActiveRecord::Migration
  def change
    add_column :sections, :shape, :string, after: :layout
  end
end
