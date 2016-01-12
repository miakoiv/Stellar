class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :order, null: false, index: true
      t.integer :amount, null: false

      t.timestamps null: false
    end
  end
end
