class AddPriceCentsIndexToPromotedItems < ActiveRecord::Migration
  def change
    add_index :promoted_items, :price_cents
  end
end
