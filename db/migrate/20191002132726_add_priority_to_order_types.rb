class AddPriorityToOrderTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :order_types, :priority, :integer, null: false, default: 0, after: :is_exported
  end
end
