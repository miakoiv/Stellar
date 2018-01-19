class AddBackgroundColorToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :background_color, :string, after: :inset
  end
end
