class AddSlugToPages < ActiveRecord::Migration
  def change
    add_column :pages, :slug, :string, null: false, after: :title
    add_index :pages, :slug
  end
end
