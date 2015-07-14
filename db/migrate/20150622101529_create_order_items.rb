class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.belongs_to :order,   null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.integer :amount
      t.timestamps null: false

      # The rest of the fields are permanent copies of
      # product attributes this order item references.
      t.string :product_code
      t.string :product_customer_code
      t.string :product_title
      t.string :product_subtitle
      t.decimal :product_sales_price, precision: 8, scale: 2
    end
  end
end
