class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.belongs_to :order,   null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.integer :amount

      t.timestamps null: false
    end
  end
end
