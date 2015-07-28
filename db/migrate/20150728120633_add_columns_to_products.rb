class AddColumnsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sales_price_modified_at, :date, after: :sales_price
    add_column :products, :cost, :decimal, precision: 8, scale: 2, after: :memo
    add_column :products, :cost_modified_at, :date, after: :cost
  end
end
