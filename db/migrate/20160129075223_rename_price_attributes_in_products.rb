class RenamePriceAttributesInProducts < ActiveRecord::Migration
  def change
    rename_column :products, :cost_cents, :cost_price_cents
    rename_column :products, :cost_modified_at, :cost_price_modified_at
    rename_column :products, :sales_price_cents, :trade_price_cents
    rename_column :products, :sales_price_modified_at, :trade_price_modified_at
  end
end
