class CreateProductsUsersJoinTable < ActiveRecord::Migration
  def change
    create_join_table :products, :users do |t|
      t.index [:user_id, :product_id], unique: true
    end
  end
end
