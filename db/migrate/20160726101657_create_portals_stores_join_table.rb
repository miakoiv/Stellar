class CreatePortalsStoresJoinTable < ActiveRecord::Migration
  def change
    create_join_table :portals, :stores do |t|
      t.index [:portal_id, :store_id], unique: true
    end
  end
end
