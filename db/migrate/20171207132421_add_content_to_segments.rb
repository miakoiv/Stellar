class AddContentToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :content, :text, after: :metadata
  end
end
