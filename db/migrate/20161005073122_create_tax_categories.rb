class CreateTaxCategories < ActiveRecord::Migration
  def change
    create_table :tax_categories do |t|
      t.belongs_to :store, index: true
      t.string :name
      t.decimal :rate, precision: 5, scale: 2
      t.boolean :included_in_retail, null: false, default: true

      t.timestamps null: false
    end
  end
end
