class AddPricingShownStockShownToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :pricing_shown, :boolean, null: false, default: true, after: :name
    add_column :groups, :stock_shown, :boolean, null: false, default: true, after: :pricing_shown
  end
end
