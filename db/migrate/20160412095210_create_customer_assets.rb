class CreateCustomerAssets < ActiveRecord::Migration
  def change
    create_table :customer_assets do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :user, null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.integer :amount, null: false, default: 0
      t.integer :value_cents, null: false, default: 0

      t.timestamps null: false
    end
  end
end
