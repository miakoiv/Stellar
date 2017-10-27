class RemovePromotedPriceCentsFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :promoted_price_cents
  end

  def down
    add_column :products, :promoted_price_cents, :integer, after: :retail_price_cents
  end
end
