class AddPromotedPriceCentsToProducts < ActiveRecord::Migration
  def up
    add_column :products, :promoted_price_cents, :integer, after: :retail_price_cents

    Product
      .where(purpose: [0, 2, 3, 5, 6])
      .where.not(retail_price_cents: nil)
      .find_each(batch_size: 50) do |product|
        lowest = product.best_promoted_item
        next if lowest.nil?
        product.update(promoted_price_cents: lowest.price_cents)
      end
  end

  def down
    remove_column :products, :promoted_price_cents
  end
end
