class AddIncludesTaxToOrderTypes < ActiveRecord::Migration
  def up
    add_column :order_types, :includes_tax, :boolean, null: false, default: true, after: :destination_id
    OrderType.reset_column_information
    OrderType.joins(:source).each do |order_type|
      order_type.update_columns includes_tax: order_type.source.price_tax_included?
    end
  end

  def down
    remove_column :order_types, :includes_tax
  end
end
