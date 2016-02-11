class AddDiscountPercentToPromotedItems < ActiveRecord::Migration
  def change
    add_column :promoted_items, :discount_percent, :decimal, precision: 5, scale: 2, after: :price_cents
  end
end
