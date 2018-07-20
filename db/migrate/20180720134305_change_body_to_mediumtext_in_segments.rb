class ChangeBodyToMediumtextInSegments < ActiveRecord::Migration
  def change
    change_column :segments, :body, :text, limit: 16777215
  end
end
