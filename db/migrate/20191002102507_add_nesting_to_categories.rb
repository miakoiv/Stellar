class AddNestingToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :nesting, :boolean, null: false, default: true, after: :filtering
  end
end
