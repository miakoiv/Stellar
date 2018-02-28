class AddShipmentIdToTransfers < ActiveRecord::Migration
  def change
    add_reference :transfers, :shipment, index: true, after: :store_id
  end
end
