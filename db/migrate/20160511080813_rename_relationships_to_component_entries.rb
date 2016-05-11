class RenameRelationshipsToComponentEntries < ActiveRecord::Migration
  def change
    rename_table :relationships, :component_entries
  end
end
