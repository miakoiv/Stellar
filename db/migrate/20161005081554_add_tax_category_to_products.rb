class AddTaxCategoryToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :tax_category, null: false, index: true, after: :retail_price_cents
  end
end
