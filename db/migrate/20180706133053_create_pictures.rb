class CreatePictures < ActiveRecord::Migration
  def up
    create_table :pictures do |t|
      t.belongs_to :image, index: true, null: false
      t.belongs_to :pictureable, polymorphic: true, index: true
      t.integer :purpose, null: false
      t.string :caption
      t.string :url
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end

    # Creates pictures from existing images, reusing images instead of
    # using duplicates of the same image based on the fingerprint.
    fingerprints = {}
    Image.find_each(batch_size: 25) do |image|
      chosen = (fingerprints[image.attachment_fingerprint] ||= image)
      Picture.create(
        image: chosen,
        pictureable: image.imageable,
        purpose: image.purpose,
        priority: image.priority,
        created_at: image.created_at,
        updated_at: image.updated_at
      )
    end
  end

  def down
    drop_table :pictures
  end
end
