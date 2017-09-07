class ChangeResourceToStoreInHostnames < ActiveRecord::Migration
  def up
    add_reference :hostnames, :store, null: false, index: true, first: true
    Hostname.reset_column_information
    Hostname.where(resource_type: 'Store').each do |hostname|
      hostname.update_columns store_id: hostname.resource_id
    end
    remove_index :hostnames, [:resource_type, :resource_id]
    remove_reference :hostnames, :resource, polymorphic: true
  end

  def down
    add_reference :hostnames, :resource, polymorphic: true, index: true, first: true
    Hostname.reset_column_information
    Hostname.all.each do |hostname|
      hostname.update_columns resource_type: 'Store', resource_id: hostname.store_id
    end
    remove_index :hostnames, :store_id
    remove_reference :hostnames, :store
  end
end
