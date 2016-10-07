class AddTaxesToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :tax_rate, :decimal, precision: 5, scale: 2, null: false, default: 0, after: :price_cents
    add_column :order_items, :price_includes_tax, :boolean, null: false, default: false, after: :tax_rate
  end
end
