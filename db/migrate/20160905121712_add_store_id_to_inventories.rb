class AddStoreIdToInventories < ActiveRecord::Migration
  def change
    add_reference :inventories, :store, index: true, after: :id
  end
end
