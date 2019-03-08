class AddGroupReferenceToOrderReportRows < ActiveRecord::Migration[5.2]
  def change
    add_reference :order_report_rows, :group, type: :integer, null: false, index: true, first: true
  end
end
