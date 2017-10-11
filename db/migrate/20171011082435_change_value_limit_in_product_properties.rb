class ChangeValueLimitInProductProperties < ActiveRecord::Migration
  def up
    change_column :product_properties, :value_i, :bigint
  end

  def down
    change_column :product_properties, :value_i, :integer
  end
end
