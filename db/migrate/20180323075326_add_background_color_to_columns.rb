class AddBackgroundColorToColumns < ActiveRecord::Migration
  def change
    add_column :columns, :background_color, :string, null: false, default: 'transparent', after: :pivot
  end
end
