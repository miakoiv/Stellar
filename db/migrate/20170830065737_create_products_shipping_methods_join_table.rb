class CreateProductsShippingMethodsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :products, :shipping_methods do |t|
      t.index :product_id
    end
  end
end
