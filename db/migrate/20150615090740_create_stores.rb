class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :erp_number, null: false
      t.string :name
      t.string :slug

      t.timestamps null: false
    end
  end
end
