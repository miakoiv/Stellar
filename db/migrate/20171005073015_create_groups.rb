class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.belongs_to :store, null: false, index: true
      t.string :name, null: false
      t.integer :price_base, null: false, default: 1
      t.decimal :price_markup_percent, precision: 5, scale: 2, null: false, default: 0
      t.boolean :price_tax_included, null: false, default: true
      t.string :appearance, null: false, default: 'default'
      t.integer :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
