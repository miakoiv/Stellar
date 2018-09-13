class AddGradientsToSections < ActiveRecord::Migration
  def change
    add_column :sections, :gradient_color, :string, null: false, default: '#FFFFFF', after: :background_color
    add_column :sections, :gradient_type, :string, after: :gradient_color
    add_column :sections, :gradient_direction, :string, after: :gradient_type
  end
end
