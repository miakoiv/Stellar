class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :user,  null: false, index: true
      t.belongs_to :order_type, index: true
      t.datetime :ordered_at
      t.datetime :approved_at
      t.string :company_name
      t.string :contact_person
      t.text :billing_address
      t.text :shipping_address
      t.text :notes
      t.timestamps null: false
      t.text :archived_copy
    end
  end
end
