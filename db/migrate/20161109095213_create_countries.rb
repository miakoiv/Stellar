class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries, id: false do |t|
      t.string :code, limit: 2, null: false
      t.string :name
    end
    add_index :countries, :code, unique: true
  end
end
