class CreateInventoryEntries < ActiveRecord::Migration
  def change
    create_table :inventory_entries do |t|
      t.belongs_to :inventory_item, null: false, index: true
      t.date :recorded_at, index: true
      t.belongs_to :source, polymorphic: true, index: true
      t.integer :amount, null: false
      t.integer :value_cents, null: false
      t.string :note

      t.timestamps null: false
    end
  end
end
