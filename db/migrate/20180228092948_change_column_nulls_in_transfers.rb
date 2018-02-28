class ChangeColumnNullsInTransfers < ActiveRecord::Migration
  def change
    change_column_null :transfers, :source_id, true
    change_column_null :transfers, :destination_id, true
  end
end
