class ChangeDefaultGroupNullInStores < ActiveRecord::Migration
  def change
    change_column_null :stores, :default_group_id, true
  end
end
