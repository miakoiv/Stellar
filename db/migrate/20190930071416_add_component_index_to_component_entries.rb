class AddComponentIndexToComponentEntries < ActiveRecord::Migration[5.2]
  def change
    add_index :component_entries, :component_id
  end
end
