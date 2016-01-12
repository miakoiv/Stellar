class AddLiveToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :live, :boolean, null: false, default: false, index: true, after: :parent_category_id
  end
end
