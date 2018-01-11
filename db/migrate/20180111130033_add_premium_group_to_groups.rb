class AddPremiumGroupToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :premium_group, after: :price_tax_included
    add_column :groups, :premium_teaser, :string, after: :premium_group_id
  end
end
