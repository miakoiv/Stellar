class AddGradientsToColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :columns, :gradient_color, :string, null: false, default: '#FFFFFF', after: :background_color
    add_column :columns, :gradient_type, :string, after: :gradient_color
    add_column :columns, :gradient_direction, :string, after: :gradient_type
    add_column :columns, :gradient_balance, :integer, null: false, default: 0, after: :gradient_direction
  end
end
