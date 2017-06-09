class AddConvertedProductPropertyValues < ActiveRecord::Migration
  def up
    add_column :product_properties, :value_i, :integer, after: :value
    add_column :product_properties, :value_f, :decimal, precision: 8, scale: 3, after: :value_i

    ProductProperty.find_each(batch_size: 100) do |product_property|
      next if product_property.string?
      numeric = product_property.value.gsub(/[^\d,.-]/, '').sub(',', '.')
      product_property.update(value_i: numeric.to_i, value_f: numeric.to_f)
    end
  end

  def down
    remove_column :product_properties, :value_i
    remove_column :product_properties, :value_f
  end
end
