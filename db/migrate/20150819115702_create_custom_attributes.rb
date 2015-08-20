class CreateCustomAttributes < ActiveRecord::Migration
  def change
    create_table :custom_attributes do |t|
      t.belongs_to :store, null: false, index: true
      t.string :name

      t.timestamps null: false
    end
  end
end
