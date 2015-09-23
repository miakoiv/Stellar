class AddDescriptionToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :description, :text, after: :name
  end
end
