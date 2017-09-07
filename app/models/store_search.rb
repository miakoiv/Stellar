#encoding: utf-8

require 'searchlight/adapters/action_view'

class StoreSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    Store.order({portal: :desc}, :name)
  end

  def search_name
    query.where('stores.name LIKE ?', "%#{name}%")
  end

  def search_hostname
    query.joins(:hostnames).where('hostnames.fqdn LIKE ?', "%#{hostname}%").distinct
  end

  def search_domain
    hostname = Hostname.arel_table
    query.joins(:hostnames).where(
      hostname[:id].in(domain).or(
        hostname[:parent_hostname_id].in(domain)
      )
    ).distinct
  end
end
