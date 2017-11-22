class AddPrepaidStockToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :prepaid_stock, :boolean, null: false, default: false, after: :payment_gateway
  end
end
