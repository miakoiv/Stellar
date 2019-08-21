class AddBordersToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :borders, :text, after: :content
  end
end
