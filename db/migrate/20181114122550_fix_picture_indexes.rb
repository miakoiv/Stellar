class FixPictureIndexes < ActiveRecord::Migration
  def change
    remove_index :pictures, [:image_id]
    remove_index :pictures, [:pictureable_type, :pictureable_id]
    add_index :pictures, [:pictureable_type, :pictureable_id, :purpose, :priority], name: :picture_master_index
  end
end
