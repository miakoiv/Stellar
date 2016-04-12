class AddPricingGroupIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :pricing_group, index: true, after: :group
    remove_column :users, :pricing_factor, :decimal, precision: 6, scale: 2, null: false, default: 1.0
  end
end
