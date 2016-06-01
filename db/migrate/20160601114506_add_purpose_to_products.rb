class AddPurposeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :purpose, :integer, null: false, default: 0, after: :store_id
    add_index :products, :purpose
  end
end
