require 'searchlight/adapters/action_view'

class StoreSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    Store.order(:name)
  end

  def search_name
    query.where('stores.name LIKE ?', "%#{name}%")
  end

  def search_hostname
    query.joins(:hostnames).where('hostnames.fqdn LIKE ?', "%#{hostname}%").distinct
  end

  def search_domain
    query.joins(:hostnames).where(hostnames: {id: domain})
      .or(
        query.joins(:hostnames).where(hostnames: {parent_hostname_id: domain})
      )
      .distinct
  end
end
