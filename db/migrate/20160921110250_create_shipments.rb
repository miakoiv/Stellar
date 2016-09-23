class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.belongs_to :order, null: false, index: true
      t.belongs_to :shipping_method
      t.string :number
      t.datetime :shipped_at
      t.datetime :cancelled_at
      t.text :metadata

      t.timestamps null: false
    end
  end
end
