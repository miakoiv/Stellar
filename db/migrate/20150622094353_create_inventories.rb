class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :purpose, null: false, default: 0
      t.string :name

      t.timestamps null: false
    end
  end
end
