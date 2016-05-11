class CreateRequisiteEntries < ActiveRecord::Migration
  def change
    create_table :requisite_entries do |t|
      t.belongs_to :product, null: false, index: true
      t.belongs_to :requisite, null: false, index: true
      t.integer :priority, null: false, default: 0
    end
  end
end
