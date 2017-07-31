class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.belongs_to :page, null: false, index: true
      t.string :layout, null: false
      t.string :width, null: false, default: 'width-page'
      t.integer :height
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
