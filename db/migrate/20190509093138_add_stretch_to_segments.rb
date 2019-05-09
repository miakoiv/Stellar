class AddStretchToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :stretch, :boolean, null: false, default: false, after: :shape
  end
end
