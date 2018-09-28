class AddDefaultPriceCentsToPromotionHandlers < ActiveRecord::Migration
  def change
    add_column :promotion_handlers, :default_price_cents, :integer, after: :description
  end
end
