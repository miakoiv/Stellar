class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.belongs_to :image, index: true, null: false
      t.belongs_to :pictureable, polymorphic: true, index: true
      t.integer :purpose, null: false
      t.string :caption
      t.string :url
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
