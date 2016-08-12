class AddVendorIdToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :vendor, index: true, after: :store_id
  end
end
