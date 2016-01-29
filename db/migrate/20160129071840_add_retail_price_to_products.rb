class AddRetailPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :retail_price_cents, :integer, after: :sales_price_modified_at
  end
end
