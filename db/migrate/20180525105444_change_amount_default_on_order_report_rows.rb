class ChangeAmountDefaultOnOrderReportRows < ActiveRecord::Migration
  def change
    change_column_default :order_report_rows, :amount, 0
  end
end
