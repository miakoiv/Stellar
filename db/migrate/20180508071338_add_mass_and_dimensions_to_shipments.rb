class AddMassAndDimensionsToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :mass, :integer, after: :pickup_point_id
    add_column :shipments, :dimension_u, :integer, after: :mass
    add_column :shipments, :dimension_v, :integer, after: :dimension_u
    add_column :shipments, :dimension_w, :integer, after: :dimension_v
  end
end
