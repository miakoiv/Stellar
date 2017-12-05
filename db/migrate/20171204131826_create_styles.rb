class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.belongs_to :store, null: false, index: true
      t.text :variables

      t.timestamps null: false
    end
  end
end
