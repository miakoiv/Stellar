class AddNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :number, :string, after: :store_id
  end
end
