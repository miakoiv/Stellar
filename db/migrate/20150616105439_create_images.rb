class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, index: true
      t.belongs_to :image_type, index: true
      t.timestamps null: false
    end
  end
end
