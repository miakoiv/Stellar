class AddPriorityToComponentEntries < ActiveRecord::Migration
  def change
    add_column :component_entries, :priority, :integer, null: false, default: 0, after: :quantity
  end
end
