class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :source, null: false, index: true
      t.belongs_to :destination, null: false, index: true
      t.string :note

      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
