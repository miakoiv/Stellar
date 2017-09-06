class DestroyPortals < ActiveRecord::Migration
  def up
    remove_index :departments, :portal_id
    remove_reference :departments, :portal

    drop_join_table :portals, :stores
    drop_table :portals

    add_reference :departments, :store, index: true, first: true
  end

  def down
    remove_index :departments, :store_id
    remove_reference :departments, :store

    create_table :portals do |t|
      t.string :domain
      t.string :name
      t.text :settings
      t.timestamps null: false
    end
    add_index :portals, :domain, unique: true

    create_join_table :portals, :stores do |t|
      t.index [:portal_id, :store_id], unique: true
    end

    add_reference :departments, :portal, index: true, first: true
  end
end
