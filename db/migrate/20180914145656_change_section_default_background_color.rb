class ChangeSectionDefaultBackgroundColor < ActiveRecord::Migration
  def change
    change_column_default :sections, :background_color, 'transparent'
  end
end
