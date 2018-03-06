#
# This migration changes history by adding transfers to existing
# shipments that were created before transfers were added.
#
# Since stock levels were changed through orders, they are left
# untouched by creating completed transfers without going through
# Transfer#complete! which would change the stock levels another time.
#
# The lot codes that were used to fulfil the orders have been lost,
# so transfer items are given the lot code "[legacy]".
#
class CreateTransfersForShipments < ActiveRecord::Migration
  def up
    Shipment.find_each(batch_size: 20) do |shipment|
      order = shipment.order
      next unless order.inventory.present? && order.requires_shipping?
      transfer = shipment.create_transfer(
        store: order.store,
        source: order.inventory,
        completed_at: order.concluded_at,
        note: "#{Order.model_name.human} #{order}"
      )
      order.order_items.tangible.each do |order_item|
        transfer.create_item_from(order_item, '[legacy]')
      end
    end
  end

  def down
    Transfer.where.not(shipment_id: nil).destroy_all
  end
end
