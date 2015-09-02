class AddIndexToProducts < ActiveRecord::Migration
  def change
    add_index :products, :code
  end
end
