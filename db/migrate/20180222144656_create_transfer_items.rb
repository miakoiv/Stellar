class CreateTransferItems < ActiveRecord::Migration
  def change
    create_table :transfer_items do |t|
      t.belongs_to :transfer, null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.belongs_to :inventory_item, null: false, index: true
      t.integer :amount, null: false, default: 0

      t.timestamps null: false
    end
  end
end
