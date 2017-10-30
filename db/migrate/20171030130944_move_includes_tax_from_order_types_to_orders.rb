class MoveIncludesTaxFromOrderTypesToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :includes_tax, :boolean, null: false, default: true, after: :order_type_id
    Order.reset_column_information
    Order.joins(order_type: :source).each do |order|
      order.update_columns includes_tax: order.order_type.source.price_tax_included?
    end
    remove_column :order_types, :includes_tax
  end

  def down
    add_column :order_types, :includes_tax, :boolean, null: false, default: true, after: :destination_id
  end
end
