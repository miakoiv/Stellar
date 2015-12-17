class AddProductScopeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :product_scope, :string, after: :slug
  end
end
