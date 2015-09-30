class CreateMeasurementUnits < ActiveRecord::Migration
  def change
    create_table :measurement_units do |t|
      t.belongs_to :base_unit, index: true
      t.integer :exponent
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
