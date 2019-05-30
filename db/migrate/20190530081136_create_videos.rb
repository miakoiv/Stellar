class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.belongs_to :videoable, polymorphic: true
      t.string :title
      t.boolean :loop, null: false, default: true
      t.boolean :muted, null: false, default: false
      t.integer :priority, null: false, default: 0
      t.timestamps
    end
  end
end
