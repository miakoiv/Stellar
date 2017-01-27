class AddIsExportedToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :is_exported, :boolean, null: false, default: false, after: :is_quote
  end
end
