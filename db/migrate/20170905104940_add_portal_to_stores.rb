class AddPortalToStores < ActiveRecord::Migration
  def change
    add_column :stores, :portal, :boolean, null: false, default: false, after: :erp_number
  end
end
