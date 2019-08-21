class AddGradientsToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :gradient_color, :string, null: false, default: '#FFFFFF', after: :background_color
    add_column :segments, :gradient_type, :string, after: :gradient_color
    add_column :segments, :gradient_direction, :string, after: :gradient_type
    add_column :segments, :gradient_balance, :integer, null: false, default: 0, after: :gradient_direction
  end
end
