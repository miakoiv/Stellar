class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.belongs_to :section, null: false, index: true
      t.belongs_to :resource, polymorphic: true, index: true
      t.integer :template, null: false, default: 0
      t.string :measure, null: false, default: 'col-12'
      t.text :body
      t.text :metadata
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
