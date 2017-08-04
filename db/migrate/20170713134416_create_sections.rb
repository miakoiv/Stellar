class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.belongs_to :page, null: false, index: true
      t.string :width, null: false, default: 'col-12'
      t.integer :layout, null: false, default: 1
      t.string :aspect_ratio
      t.string :alignment, null: false, default: 'none'
      t.string :background_color, null: false, default: '#FFFFFF'
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
