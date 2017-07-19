class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.belongs_to :page, null: false, index: true
      t.string :layout, null: false
      t.integer :width, default: 12
      t.integer :height
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
