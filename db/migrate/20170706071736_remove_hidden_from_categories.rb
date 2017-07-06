class RemoveHiddenFromCategories < ActiveRecord::Migration
  def change
    remove_column :categories, :hidden, :boolean, null: false, default: false, after: :live
  end
end
