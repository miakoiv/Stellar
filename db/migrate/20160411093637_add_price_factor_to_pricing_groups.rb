class AddPriceFactorToPricingGroups < ActiveRecord::Migration
  def change
    add_column :pricing_groups, :price_factor, :decimal, precision: 4, scale: 3, null: false, default: 1.0, after: :name
  end
end
