class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :store, null: false, index: true
      t.string :name
      t.string :appearance, null: false, default: 'default'
      t.boolean :searchable, null: false, default: true
      t.string :slug, null: false, index: true

      t.timestamps null: false
    end
  end
end
