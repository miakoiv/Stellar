class AddHasBillingAddressToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :has_billing_address, :boolean, null: false, default: false, after: :contact_person
  end
end
