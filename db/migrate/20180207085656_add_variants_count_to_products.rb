class AddVariantsCountToProducts < ActiveRecord::Migration
  def up
    add_column :products, :variants_count, :integer, null: false, default: 0, after: :primary_variant_id

    Product.find_each(batch_size: 50) do |product|
      Product.reset_counters(product.id, :variants)
    end
  end

  def down
    remove_column :products, :variants_count
  end
end
