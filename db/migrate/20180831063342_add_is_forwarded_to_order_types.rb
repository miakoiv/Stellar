class AddIsForwardedToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :is_forwarded, :boolean, null: false, default: false, after: :payment_gateway
  end
end
