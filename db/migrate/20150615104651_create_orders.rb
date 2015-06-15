class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :user, null: false, index: true
      t.belongs_to :order_type, null: false, index: true

      t.timestamps null: false
    end
  end
end
