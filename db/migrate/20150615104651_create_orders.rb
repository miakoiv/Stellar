class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :user,  null: false, index: true
      t.belongs_to :order_type, index: true
      t.datetime :ordered_at
      t.timestamps null: false
    end
  end
end
