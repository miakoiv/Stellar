class AddProductsTagsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :products, :tags do |t|
      t.index [:product_id, :tag_id], unique: true
    end
  end
end
