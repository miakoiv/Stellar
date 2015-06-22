class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.belongs_to :inventory, null: false, index: true
      t.belongs_to :product,   null: false, index: true
      t.integer :amount

      t.timestamps null: false
    end
  end
end
