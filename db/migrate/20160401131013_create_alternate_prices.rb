class CreateAlternatePrices < ActiveRecord::Migration
  def change
    create_table :alternate_prices do |t|
      t.belongs_to :pricing_group, null: false, index: true
      t.belongs_to :product, null: false, index: true
      t.integer :retail_price_cents, null: false

      t.timestamps null: false
    end
  end
end
