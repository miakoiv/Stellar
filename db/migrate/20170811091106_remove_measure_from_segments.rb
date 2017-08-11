class RemoveMeasureFromSegments < ActiveRecord::Migration
  def change
    remove_column :segments, :measure, :string, null: false, default: 'col-12'
  end
end
