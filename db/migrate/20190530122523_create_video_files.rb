class CreateVideoFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :video_files do |t|
      t.belongs_to :video, type: :integer, null: false, index: true
      t.attachment :attachment
      t.timestamps
    end
  end
end
