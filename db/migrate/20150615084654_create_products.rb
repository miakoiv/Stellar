class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :brand_id
      t.integer :category_id
      t.string :name

      t.timestamps null: false
    end
  end
end
