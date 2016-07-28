class CreatePortals < ActiveRecord::Migration
  def change
    create_table :portals do |t|
      t.string :domain
      t.string :name
      t.text :settings

      t.timestamps null: false
    end
    add_index :portals, :domain, unique: true
  end
end
