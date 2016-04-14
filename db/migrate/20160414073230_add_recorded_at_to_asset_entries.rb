class AddRecordedAtToAssetEntries < ActiveRecord::Migration
  def change
    add_column :asset_entries, :recorded_at, :date, after: :customer_asset_id
  end
end
