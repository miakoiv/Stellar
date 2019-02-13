require 'searchlight/adapters/action_view'

class InventoryCheckSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    InventoryCheck.all
  end

  def search_store
    query.where(store: store)
  end

  def search_inventory
    query.where(inventory: inventory)
  end

  def search_keyword
    query.where("note LIKE ?", "%#{keyword}%")
  end
end
