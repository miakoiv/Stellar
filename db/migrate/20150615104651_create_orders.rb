class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :user,  null: false, index: true
      t.belongs_to :order_type, index: true
      t.datetime :ordered_at
      t.date :shipping_at
      t.datetime :approved_at
      t.string :company_name
      t.string :contact_person
      t.text :billing_address
      t.text :shipping_address
      t.text :notes
      t.timestamps null: false

      # The rest of the fields are permanent copies of
      # store, user, and order type attributes.
      t.string :store_name
      t.string :store_contact_person_name
      t.string :store_contact_person_email
      t.string :user_name
      t.string :user_email
      t.string :order_type_name
    end
  end
end
