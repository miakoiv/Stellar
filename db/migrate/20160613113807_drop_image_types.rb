class DropImageTypes < ActiveRecord::Migration
  def up
    drop_table :image_types
    remove_column :images, :image_type_id
  end

  def down
    create_table :image_types do |t|
      t.integer :purpose, null: false, default: 0
      t.string :name
      t.boolean :bitmap, null: false, default: true
      t.timestamps null: false
    end
    add_column :images, :image_type_id, :integer, after: :imageable_type
  end
end
