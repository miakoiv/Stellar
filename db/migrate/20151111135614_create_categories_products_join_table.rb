class CreateCategoriesProductsJoinTable < ActiveRecord::Migration
  def up
    create_join_table :categories, :products do |t|
      t.index [:category_id, :product_id], unique: true
      #t.index [:product_id, :category_id], unique: true
    end

    # Run this migration only after having specified the habtm
    # between Category and Product.
    Product.all.each do |product|
      next if product.category_id.nil?
      product.update(category_ids: [product.category_id])
    end

    remove_index :products, column: :category_id
    remove_column :products, :category_id
  end

  def down
    add_column :products, :category_id, :integer, after: :store_id
    add_index :products, [:category_id]

    Product.all.each do |product|
      next unless product.categories.any?
      product.update(category_id: product.categories.first.id)
    end

    drop_table :categories_products
  end
end
