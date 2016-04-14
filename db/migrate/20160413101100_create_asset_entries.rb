class CreateAssetEntries < ActiveRecord::Migration
  def change
    create_table :asset_entries do |t|
      t.belongs_to :customer_asset, null: false, index: true
      t.belongs_to :source, polymorphic: true, index: true
      t.integer :amount, null: false
      t.integer :value_cents, null: false
      t.string :note

      t.timestamps null: false
    end
  end
end
