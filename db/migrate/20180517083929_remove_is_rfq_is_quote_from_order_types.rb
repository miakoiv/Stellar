class RemoveIsRfqIsQuoteFromOrderTypes < ActiveRecord::Migration
  def change
    remove_column :order_types, :is_quote, :boolean, null: false, default: false, after: :prepaid_stock
    remove_column :order_types, :is_rfq, :boolean, null: false, default: false, after: :prepaid_stock
  end
end
