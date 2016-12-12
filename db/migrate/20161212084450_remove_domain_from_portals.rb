class RemoveDomainFromPortals < ActiveRecord::Migration
  def change
    remove_column :portals, :domain, :string, index: true
  end
end
