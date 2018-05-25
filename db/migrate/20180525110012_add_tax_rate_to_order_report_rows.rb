class AddTaxRateToOrderReportRows < ActiveRecord::Migration
  def change
    add_column :order_report_rows, :tax_rate, :decimal, precision: 5, scale: 2, null: false, default: 0, after: :total_with_tax_cents
  end
end
