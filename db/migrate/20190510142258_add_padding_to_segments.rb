class AddPaddingToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :padding_vertical, :integer, null: false, default: 0, after: :inset
    add_column :segments, :padding_horizontal, :integer, null: false, default: 0, after: :padding_vertical
  end
end
