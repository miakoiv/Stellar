class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.belongs_to :store, index: true, null: false
      t.belongs_to :customer, index: true, null: false
      t.string :stripe_plan_id, null: false
      t.string :stripe_id, null: false
      t.date :first_date
      t.date :last_date
      t.integer :status

      t.timestamps null: false
    end
  end
end
