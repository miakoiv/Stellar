class RemoveAdjustmentMultiplierFromOrderTypes < ActiveRecord::Migration
  def up
    remove_column :order_types, :adjustment_multiplier
  end

  def down
    add_column :order_types, :adjustment_multiplier, :integer, null: false, default: -1, after: :store_id
  end
end
