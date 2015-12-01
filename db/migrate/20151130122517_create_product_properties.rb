class CreateProductProperties < ActiveRecord::Migration
  def change
    create_table :product_properties do |t|
      t.belongs_to :product, null: false, index: true
      t.belongs_to :property, null: false, index: true
      t.string :value, null: false
      t.timestamps null: false
    end
  end
end
