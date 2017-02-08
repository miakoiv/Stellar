class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :purpose, null: false, default: 1
      t.belongs_to :page, null: false, index: true
      t.string :title
      t.text :content
      t.integer :priority

      t.timestamps null: false
    end
  end
end
