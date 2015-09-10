class AddSlugToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :slug, :string, null: false, after: :name
    add_index :categories, :slug
  end
end
