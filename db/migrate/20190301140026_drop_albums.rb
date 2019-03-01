class DropAlbums < ActiveRecord::Migration[5.2]
  def change
    drop_table :albums do |t|
      t.belongs_to :store, null: false, index: true
      t.string :title
      t.text :description
    end
  end
end
