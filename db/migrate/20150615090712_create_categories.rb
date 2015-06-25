class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.belongs_to :brand, null: false, index: true
      t.belongs_to :parent_category, index: true
      t.string :name

      t.integer :priority
      t.timestamps null: false
    end
  end
end
