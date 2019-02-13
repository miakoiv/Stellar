require 'searchlight/adapters/action_view'

class TransferSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Transfer.manual
  end

  def search_store
    query.where(store: store)
  end

  def search_source
    query.where(source: source)
  end

  def search_destination
    query.where(destination: destination)
  end

  def search_keyword
    query.where("note LIKE ?", "%#{keyword}%")
  end
end
