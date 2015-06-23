class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.integer :matfox_customer, null: false
      t.string :name

      t.timestamps null: false
    end
  end
end
