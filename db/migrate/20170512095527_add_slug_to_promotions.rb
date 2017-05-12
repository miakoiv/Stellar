class AddSlugToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :slug, :string, null: false, after: :name
    add_index :promotions, :slug
  end
end
