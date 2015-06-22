class CreateOrderTypes < ActiveRecord::Migration
  def change
    create_table :order_types do |t|
      t.references :inventory, null: false
      t.integer :adjustment_multiplier, null: false, default: -1
      t.string :name

      t.timestamps null: false
    end
  end
end
