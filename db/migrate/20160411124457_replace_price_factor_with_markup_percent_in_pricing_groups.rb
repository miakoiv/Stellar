class ReplacePriceFactorWithMarkupPercentInPricingGroups < ActiveRecord::Migration
  def change
    remove_column :pricing_groups, :price_factor, :decimal, precision: 4, scale: 3, null: false, default: 1.0
    add_column :pricing_groups, :markup_percent, :decimal, precision: 5, scale: 2, null: false, default: 0, after: :name
  end
end
