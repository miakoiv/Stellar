class CreateAlbumsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :albums, :pages do |t|
      # t.index [:album_id, :page_id]
      t.index [:page_id, :album_id], unique: true
    end
  end
end
