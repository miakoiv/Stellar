class RemoveTotalValueCentsFromOrderReportRows < ActiveRecord::Migration
  def change
    remove_column :order_report_rows, :total_value_cents, :integer, null: false, after: :amount
  end
end
