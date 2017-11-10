class AddFilteringToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :filtering, :boolean, null: false, default: false, after: :product_scope
  end
end
