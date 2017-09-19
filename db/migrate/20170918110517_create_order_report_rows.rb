class CreateOrderReportRows < ActiveRecord::Migration
  def change
    create_table :order_report_rows do |t|
      t.belongs_to :order_type, null: false, index: true
      t.belongs_to :user, index: true
      t.string :shipping_country_code, limit: 2, index: true
      t.belongs_to :product, null: false, index: true
      t.date :ordered_at, null: false, index: true
      t.integer :amount, null: false
      t.integer :total_value_cents, null: false

      t.timestamps null: false
    end
  end
end
