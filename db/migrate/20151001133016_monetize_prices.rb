class MonetizePrices < ActiveRecord::Migration
  def change
    add_column :products, :cost_cents, :integer, after: :memo
    remove_column :products, :cost, :decimal, precision: 8, scale: 2
    add_column :products, :sales_price_cents, :integer, after: :cost_modified_at
    remove_column :products, :sales_price, :decimal, precision: 8, scale: 2

    add_column :order_items, :price_cents, :integer, after: :amount
    remove_column :order_items, :price, :decimal, precision: 8, scale: 2

    add_column :promoted_items, :price_cents, :integer, after: :product_id
    remove_column :promoted_items, :price, :decimal, precision: 8, scale: 2

    add_column :inventory_items, :value_cents, :integer, after: :amount
    remove_column :inventory_items, :value, :decimal, precision: 8, scale: 2

  end
end
