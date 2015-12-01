class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.belongs_to :store, null: false, index: true
      t.integer :value_type, null: false
      t.belongs_to :measurement_unit, index: true
      t.boolean :unit_pricing, null: false, default: false
      t.boolean :searchable, null: false, default: false
      t.string :name

      t.integer :priority
      t.timestamps null: false
    end
  end
end
