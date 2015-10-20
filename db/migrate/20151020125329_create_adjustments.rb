class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.belongs_to :adjustable, polymorphic: true, index: true
      t.belongs_to :source, polymorphic: true, index: true
      t.string :label
      t.integer :amount_cents

      t.timestamps null: false
    end
  end
end
