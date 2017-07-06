class ChangeLiveDefaultInCategories < ActiveRecord::Migration
  def change
    change_column_default :categories, :live, true
  end
end
