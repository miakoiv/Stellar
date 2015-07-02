class CreateImageTypes < ActiveRecord::Migration
  def change
    create_table :image_types do |t|
      t.integer :purpose, null: false, default: 0
      t.string :name
      t.boolean :bitmap, null: false, default: true
      t.timestamps null: false
    end
  end
end
