# Converts existing User.belongs_to :pricing_group to HABTM, by
# creating a join table and populating it with existing
# pricing_group_id, user_id pairs. Finally drops the pricing_group_id
# column from users.
#
class CreatePricingGroupsUsersJoinTable < ActiveRecord::Migration
  def up
    create_join_table :pricing_groups, :users do |t|
      t.index [:pricing_group_id, :user_id], unique: true
    end
    execute <<-SQL
      INSERT INTO pricing_groups_users
      SELECT DISTINCT pricing_group_id, id AS user_id
        FROM users WHERE pricing_group_id IS NOT NULL
    SQL
    remove_index :users, :pricing_group_id
    remove_reference :users, :pricing_group
  end

  def down
    add_reference :users, :pricing_group, index: true, after: :group
    drop_join_table :pricing_groups, :users
  end
end
