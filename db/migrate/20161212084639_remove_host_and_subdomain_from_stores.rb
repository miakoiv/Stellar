class RemoveHostAndSubdomainFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :host, :string, index: true
    remove_column :stores, :subdomain, :string
  end
end
