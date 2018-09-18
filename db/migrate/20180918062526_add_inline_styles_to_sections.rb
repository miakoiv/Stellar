class AddInlineStylesToSections < ActiveRecord::Migration
  def change
    add_column :sections, :inline_styles, :text, after: :fixed_background
  end
end
