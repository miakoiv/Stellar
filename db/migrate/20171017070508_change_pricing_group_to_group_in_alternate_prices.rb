class ChangePricingGroupToGroupInAlternatePrices < ActiveRecord::Migration
  def change
    rename_column :alternate_prices, :pricing_group_id, :group_id
  end
end
