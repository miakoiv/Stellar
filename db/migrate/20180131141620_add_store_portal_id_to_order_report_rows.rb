class AddStorePortalIdToOrderReportRows < ActiveRecord::Migration
  def change
    add_reference :order_report_rows, :store_portal, index: true, after: :user_id
  end
end
