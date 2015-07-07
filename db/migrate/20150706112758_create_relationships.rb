class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string :parent_code,  null: false, index: true
      t.string :product_code, null: false, index: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
