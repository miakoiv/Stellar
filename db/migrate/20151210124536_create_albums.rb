class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.belongs_to :store,    null: false, index: true
      t.string :title
      t.text :description
      t.timestamps null: false
    end
  end
end
