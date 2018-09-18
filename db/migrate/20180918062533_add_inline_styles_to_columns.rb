class AddInlineStylesToColumns < ActiveRecord::Migration
  def change
    add_column :columns, :inline_styles, :text, after: :background_color
  end
end
