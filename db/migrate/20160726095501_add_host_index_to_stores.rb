class AddHostIndexToStores < ActiveRecord::Migration
  def change
    add_index :stores, :host, unique: true
  end
end
