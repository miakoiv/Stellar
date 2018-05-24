class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.belongs_to :store, null: false, index: true
      t.string :title
      t.text :content
      t.boolean :mandatory, null: false, default: true
      t.datetime :accepted_at
      t.belongs_to :accepted_by

      t.timestamps null: false
    end
  end
end
