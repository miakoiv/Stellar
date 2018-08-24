class CreateInventoryChecks < ActiveRecord::Migration
  def change
    create_table :inventory_checks do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :inventory, null: false, index: true
      t.string :note
      t.datetime :completed_at

      t.timestamps null: false
    end
  end
end
