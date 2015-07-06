class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.belongs_to :parent,  null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
