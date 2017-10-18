class DropPricingGroupsUsersJoinTable < ActiveRecord::Migration
  def up
    drop_join_table :pricing_groups, :users
  end

  def down
    create_join_table :pricing_groups, :users do |t|
      t.index [:pricing_group_id, :user_id], unique: true
    end
  end
end
