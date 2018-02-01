class AddStorePortalIdToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :store_portal, after: :store_id
  end
end
