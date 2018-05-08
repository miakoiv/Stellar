class AddPackageTypeToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :package_type, :string, after: :pickup_point_id
  end
end
