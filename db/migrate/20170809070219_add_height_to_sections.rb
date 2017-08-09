class AddHeightToSections < ActiveRecord::Migration
  def change
    add_column :sections, :height, :integer, after: :layout
  end
end
