class RemovePriorityFromGroups < ActiveRecord::Migration[5.2]
  def change
    remove_column :groups, :priority, :integer, null: false, default: 0, after: :apperance
  end
end
