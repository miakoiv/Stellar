class AddExpiresAtToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :expires_at, :date, after: :value_cents
  end
end
