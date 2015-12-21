class AddPaymentGatewayToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :payment_gateway, :string, after: :has_payment
  end
end
