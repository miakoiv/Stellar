class ChangeRetailPriceCentsToPriceCentsInAlternatePrices < ActiveRecord::Migration
  def change
    rename_column :alternate_prices, :retail_price_cents, :price_cents
  end
end
