class AddMeasurementsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :mass, :integer, after: :memo
    add_column :products, :dimension_u, :integer, after: :mass
    add_column :products, :dimension_v, :integer, after: :dimension_u
    add_column :products, :dimension_w, :integer, after: :dimension_v
  end
end
