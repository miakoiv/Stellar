class AddMeasurementUnitIdUnitPricingToCustomAttributes < ActiveRecord::Migration
  def change
    add_reference :custom_attributes, :measurement_unit, after: :store_id
    add_column :custom_attributes, :unit_pricing, :boolean, null: false, default: false, after: :measurement_unit_id
  end
end
