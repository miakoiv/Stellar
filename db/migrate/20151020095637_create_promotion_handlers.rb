class CreatePromotionHandlers < ActiveRecord::Migration
  def change
    create_table :promotion_handlers do |t|
      t.string :type, null: false
      t.string :name
      t.text :description
      t.integer :order_total_cents
      t.integer :required_items
      t.integer :discount_percent
      t.timestamps null: false
    end
  end
end
