class AddDefaultQuantityToComponentEntries < ActiveRecord::Migration
  def up
    change_column_null :component_entries, :quantity, false, 1
    change_column_default :component_entries, :quantity, 1
  end

  def down
    change_column_null :component_entries, :quantity, true
    change_column_default :component_entries, :quantity, nil
  end
end
