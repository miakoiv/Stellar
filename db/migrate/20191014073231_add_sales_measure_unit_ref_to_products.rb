class AddSalesMeasureUnitRefToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :sales_measure_unit, type: :integer, index: false, after: :vendor_id
  end
end
