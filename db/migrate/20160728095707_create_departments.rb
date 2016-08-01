class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.belongs_to :portal, index: true
      t.string :name
      t.string :slug
      t.integer :priority

      t.timestamps null: false
    end
  end
end
