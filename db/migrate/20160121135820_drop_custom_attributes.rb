class DropCustomAttributes < ActiveRecord::Migration
  def up
    drop_table :custom_attributes
  end

  def down
    create_table :custom_attributes do |t|
      t.belongs_to :store, null: false, index: true
      t.integer :attribute_type, null: false, default: 0
      t.belongs_to :measurement_unit
      t.string :name
      t.boolean :unit_pricing, default: false, null: false
      t.boolean :searchable, default: false, null: false

      t.timestamps null: false
    end
  end
end
