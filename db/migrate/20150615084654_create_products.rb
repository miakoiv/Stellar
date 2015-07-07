class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :store,    null: false, index: true
      t.belongs_to :category, index: true
      t.string :code
      t.string :customer_code
      t.string :title
      t.string :subtitle
      t.text :description
      t.text :memo

      t.integer :priority
      t.timestamps null: false
    end
  end
end
