class DropPricingGroups < ActiveRecord::Migration
  def up
    drop_table :pricing_groups
  end

  def down
    create_table :pricing_groups do |t|
      t.belongs_to :store, index: true
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
