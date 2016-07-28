class AddSubdomainToStores < ActiveRecord::Migration
  def change
    add_column :stores, :subdomain, :string, after: :host
  end
end
