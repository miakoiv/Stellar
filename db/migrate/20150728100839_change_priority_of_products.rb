class ChangePriorityOfProducts < ActiveRecord::Migration
  def change
    change_column_null :products, :priority, false
    change_column_default :products, :priority, 0
  end
end
