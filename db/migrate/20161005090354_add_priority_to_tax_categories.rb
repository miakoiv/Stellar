class AddPriorityToTaxCategories < ActiveRecord::Migration
  def change
    add_column :tax_categories, :priority, :integer, null: false, default: 0, after: :included_in_retail
  end
end
