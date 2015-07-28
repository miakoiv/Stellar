class ChangePriorityOfImages < ActiveRecord::Migration
  def change
    change_column_null :images, :priority, false
    change_column_default :images, :priority, 0
  end
end
