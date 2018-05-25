class AddTotalsBreakdownToOrderReportRows < ActiveRecord::Migration
  def change
    add_column :order_report_rows, :total_sans_tax_cents, :integer, null: false, default: 0, after: :total_value_cents
    add_column :order_report_rows, :total_tax_cents, :integer, null: false, default: 0, after: :total_sans_tax_cents
    add_column :order_report_rows, :total_with_tax_cents, :integer, null: false, default: 0, after: :total_tax_cents
  end
end
