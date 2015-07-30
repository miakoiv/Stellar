class AddHasShippingHasPaymentToOrderType < ActiveRecord::Migration
  def change
    add_column :order_types, :has_shipping, :boolean, null: false, default: false, after: :name
    add_column :order_types, :has_payment, :boolean, null: false, default: false, after: :has_shipping
  end
end
