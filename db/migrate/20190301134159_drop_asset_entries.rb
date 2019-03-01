class DropAssetEntries < ActiveRecord::Migration[5.2]
  def change
    drop_table :asset_entries do |t|
      t.belongs_to :customer_asset, null: false, index: true
      t.date :recorded_at
      t.belongs_to :source, polymorphic: true, index: true
      t.integer :amount, null: false
      t.integer :value_cents, null: false
      t.string :note
    end
  end
end
