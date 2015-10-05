class AddIsQuoteToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :is_quote, :boolean, null: false, default: false, after: :has_payment
  end
end
