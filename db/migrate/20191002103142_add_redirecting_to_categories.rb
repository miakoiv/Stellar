class AddRedirectingToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :redirecting, :boolean, null: false, default: false, after: :nesting
  end
end
