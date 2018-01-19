class AddBackgroundColorToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :background_color, :string, null: false, default: 'transparent', after: :inset
  end
end
