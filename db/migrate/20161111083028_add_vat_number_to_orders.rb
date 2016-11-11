class AddVatNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :vat_number, :string, after: :external_number
  end
end
