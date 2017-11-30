class AddNumberToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :number, :string, after: :order_id
  end
end
