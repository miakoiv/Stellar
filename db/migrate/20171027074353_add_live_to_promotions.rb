class AddLiveToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :live, :boolean, null: false, default: false, after: :promotion_handler_type
  end
end
