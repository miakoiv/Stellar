class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :product, null: false, index: true
      t.references :component, null: false
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
