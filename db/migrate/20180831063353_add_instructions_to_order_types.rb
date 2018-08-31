class AddInstructionsToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :instructions, :text, after: :label
  end
end
