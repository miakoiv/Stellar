class CreateShippingMethods < ActiveRecord::Migration
  def change
    create_table :shipping_methods do |t|
      t.belongs_to :store, null: false, index: true
      t.string :name, null: false
      t.string :shipping_gateway
      t.text :description

      t.timestamps null: false
    end
  end
end
