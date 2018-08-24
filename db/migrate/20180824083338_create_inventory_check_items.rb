class CreateInventoryCheckItems < ActiveRecord::Migration
  def change
    create_table :inventory_check_items do |t|
      t.belongs_to :inventory_check, null: false, index: true
      t.belongs_to :inventory_item, index: true
      t.belongs_to :product, null: false, index: true
      t.string :lot_code
      t.date :expires_at
      t.integer :amount, null: false, default: 1

      t.timestamps null: false
    end
  end
end
