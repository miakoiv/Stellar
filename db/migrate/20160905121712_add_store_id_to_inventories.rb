class AddStoreIdToInventories < ActiveRecord::Migration
  def change
    add_reference :inventories, :store, index: true
  end
end
