class CreateImageTypes < ActiveRecord::Migration
  def change
    create_table :image_types do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
