class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.belongs_to :brand, null: false, index: true
      t.string :name

      t.timestamps null: false
    end
  end
end
