class AddParentHostnameRemoveSubdomainToHostnames < ActiveRecord::Migration
  def up
    add_reference :hostnames, :parent_hostname, index: true, after: :resource_id
    Hostname.where(is_subdomain: true).each do |subdomain|
      domain = Hostname.find_by(fqdn: subdomain.fqdn.split('.')[-2,2].join('.'))
      subdomain.update parent_hostname_id: domain.id
    end
    remove_column :hostnames, :is_subdomain
  end

  def down
    add_column :hostnames, :is_subdomain, :boolean, null: false, default: false, after: :fqdn
    Hostname.where.not(parent_hostname_id: nil).update_all is_subdomain: true
    remove_reference :hostnames, :parent_hostname
  end
end
