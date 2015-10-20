class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.belongs_to :store, null: false, index: true
      t.belongs_to :promotion_handler, null: false
      t.string :name
      t.date :first_date
      t.date :last_date

      t.timestamps null: false
    end
  end
end
