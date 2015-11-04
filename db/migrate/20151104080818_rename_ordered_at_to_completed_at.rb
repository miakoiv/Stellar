class RenameOrderedAtToCompletedAt < ActiveRecord::Migration
  def change
    rename_column :orders, :ordered_at, :completed_at
  end
end
