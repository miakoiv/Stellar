class DropAlbumsJoinTable < ActiveRecord::Migration
  def change
    drop_join_table :albums, :pages do |t|
      t.index [:page_id, :album_id], unique: true
    end
  end
end
