class AddInlineStylesToSegments < ActiveRecord::Migration
  def change
    add_column :segments, :inline_styles, :text, after: :content
  end
end
