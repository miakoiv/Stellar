class RenamePriceMarkupPercentToPriceModifierInGroups < ActiveRecord::Migration
  def change
    rename_column :groups, :price_markup_percent, :price_modifier
  end
end
