class AddViewModeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :view_mode, :string, null: false, default: 'product-grid', after: :filtering
  end
end
