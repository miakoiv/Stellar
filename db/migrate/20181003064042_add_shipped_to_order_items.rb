class AddShippedToOrderItems < ActiveRecord::Migration
  def up
    add_column :order_items, :shipped, :integer, after: :amount

    # For each order item that has associated transfer items,
    # update the shipped amount from complete shipments.
    OrderItem.joins(:transfer_items).each do |order_item|
      shipped = order_item.transfer_items
        .joins(transfer: :shipment)
        .merge(Shipment.complete)
        .sum(:amount)
      order_item.update_columns(shipped: shipped)
    end
  end

  def down
    remove_column :order_items, :shipped
  end
end
