class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :name, null: false, default: ''
      t.string :phone, null: false, default: ''
      t.string :company, null: false, default: ''
      t.string :address1, null: false
      t.string :address2, null: false, default: ''
      t.string :postalcode, null: false
      t.string :city, null: false
      t.string :country_code, null: false, limit: 2

      t.timestamps
    end
  end
end
