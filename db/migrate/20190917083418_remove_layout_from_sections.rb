class RemoveLayoutFromSections < ActiveRecord::Migration[5.2]
  def change
    remove_column :sections, :layout, :string, null: false, default: 'twelve', after: :width
  end
end
