class AddInfiniteStockToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :infinite_stock, :boolean, null: false, default: false, after: :dimension_w
  end
end
