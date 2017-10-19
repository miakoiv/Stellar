class AddLabelToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :label, :string, after: :name
  end
end
