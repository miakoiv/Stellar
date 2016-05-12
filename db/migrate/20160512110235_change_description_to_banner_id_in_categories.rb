class ChangeDescriptionToBannerIdInCategories < ActiveRecord::Migration
  def change
    remove_column :categories, :description, :text, after: :name
    add_column :categories, :banner_id, :integer, after: :parent_category_id
  end
end
