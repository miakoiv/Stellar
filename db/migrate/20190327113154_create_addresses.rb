class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :name
      t.string :phone
      t.string :company
      t.string :address1
      t.string :address2
      t.string :postalcode
      t.string :city
      t.string :country_code, null: false, limit: 2

      t.timestamps
    end
  end
end
