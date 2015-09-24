class CreatePromotedItems < ActiveRecord::Migration
  def change
    create_table :promoted_items do |t|
      t.belongs_to :promotion, null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.decimal :price, precision: 8, scale: 2
      t.integer :amount_available
      t.integer :amount_sold, null: false, default: 0

      t.timestamps null: false
    end
  end
end
