class AddSlugToProducts < ActiveRecord::Migration
  def change
    add_column :products, :slug, :string, null: false, after: :title
    add_index :products, :slug
  end
end
