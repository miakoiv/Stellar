class ChangeResourceToStoreInHostnames < ActiveRecord::Migration
  def up
    add_reference :hostnames, :store, null: false, index: true, first: true
    Hostname.where(resource_type: 'Store').each do |hostname|
      hostname.update store_id: hostname.resource_id
    end
    remove_index :hostnames, [:resource_type, :resource_id]
    remove_reference :hostnames, :resource, polymorphic: true
  end

  def down
    add_reference :hostnames, :resource, polymorphic: true, index: true, first: true
    Hostname.all.each do |hostname|
      hostname.update resource: Store.find(hostname.store_id)
    end
    remove_index :hostnames, :store_id
    remove_reference :hostnames, :store
  end
end
