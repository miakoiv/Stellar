class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.belongs_to :store
      t.integer :purpose, null: false, default: 0
      t.boolean :fuzzy, null: false, default: false
      t.string :name

      t.timestamps null: false
    end
  end
end
