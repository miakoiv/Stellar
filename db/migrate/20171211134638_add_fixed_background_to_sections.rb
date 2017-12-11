class AddFixedBackgroundToSections < ActiveRecord::Migration
  def change
    add_column :sections, :fixed_background, :boolean, null: false, default: false, after: :background_color
  end
end
