class AddItemsTotalCentsToPromotionHandlers < ActiveRecord::Migration
  def change
    add_column :promotion_handlers, :items_total_cents, :integer, after: :required_items
  end
end
