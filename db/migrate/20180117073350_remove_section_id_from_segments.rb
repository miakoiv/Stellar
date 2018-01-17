class RemoveSectionIdFromSegments < ActiveRecord::Migration
  def change
    remove_reference :segments, :section, null: false, index: true, first: true
  end
end
