class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.belongs_to :product, null: false, index: true
      t.timestamps null: false
    end
  end
end
