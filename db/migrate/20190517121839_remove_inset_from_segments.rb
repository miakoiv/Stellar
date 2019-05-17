class RemoveInsetFromSegments < ActiveRecord::Migration[5.2]
  def change
    remove_column :segments, :inset, :string, null: false, default: 'inset-none', after: :margin_bottom
  end
end
