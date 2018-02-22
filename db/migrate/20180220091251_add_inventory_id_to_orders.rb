class AddInventoryIdToOrders < ActiveRecord::Migration
  def up
    add_reference :orders, :inventory, index: true, after: :customer_id

    Store.all.each do |store|
      inventory = store.default_inventory
      next if inventory.nil?
      store.orders.update_all(inventory_id: inventory.id)
    end
  end

  def down
    remove_reference :orders, :inventory
  end
end
