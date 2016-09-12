class RemoveInventoryCodeFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :inventory_code, :string, after: :erp_number
  end
end
