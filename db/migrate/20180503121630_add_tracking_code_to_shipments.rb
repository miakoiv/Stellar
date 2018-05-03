class AddTrackingCodeToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :tracking_code, :string, after: :number
  end
end
