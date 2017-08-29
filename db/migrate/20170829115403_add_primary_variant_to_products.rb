class AddPrimaryVariantToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :primary_variant, after: :master_product_id
  end
end
