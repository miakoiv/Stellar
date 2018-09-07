class AddConcludedAtToInventoryChecks < ActiveRecord::Migration
  def change
    add_column :inventory_checks, :concluded_at, :datetime, after: :completed_at
  end
end
