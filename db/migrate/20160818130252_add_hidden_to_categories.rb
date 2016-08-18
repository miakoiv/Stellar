class AddHiddenToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :hidden, :bool, null: false, default: false, after: :live
  end
end
