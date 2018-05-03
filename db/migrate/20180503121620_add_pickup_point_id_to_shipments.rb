class AddPickupPointIdToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :pickup_point_id, :string, after: :number
  end
end
