class AddMasterProductIdToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :master_product, index: true, after: :store_id
  end
end
