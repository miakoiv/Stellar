class CreateLinkedProductsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :products, :linked_products do |t|
      # t.index [:product_id, :linked_product_id]
      t.index [:product_id, :linked_product_id], unique: true, name: 'linked_products_by_product'
    end
  end
end
