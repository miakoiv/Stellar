class AddSubtitleToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :subtitle, :text, after: :name
  end
end
