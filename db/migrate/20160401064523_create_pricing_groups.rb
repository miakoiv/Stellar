class CreatePricingGroups < ActiveRecord::Migration
  def change
    create_table :pricing_groups do |t|
      t.belongs_to :store, index: true
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
