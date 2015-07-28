class ChangePriorityOfCategories < ActiveRecord::Migration
  def change
    change_column_null :categories, :priority, false
    change_column_default :categories, :priority, 0
  end
end
