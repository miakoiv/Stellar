class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.belongs_to :contact_person, null: false
      t.integer :erp_number
      t.boolean :local_inventory, null: false, default: false
      t.string :inventory_code
      t.string :name
      t.string :slug
      t.string :theme

      t.timestamps null: false
    end
  end
end
