class CreateOrdersPromotionsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :orders, :promotions do |t|
      t.index [:order_id, :promotion_id], unique: true
    end
  end
end
