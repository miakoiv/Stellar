class AddSafetyStockToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :safety_stock, :integer, null: false, default: 0, after: :dimension_w
  end
end
