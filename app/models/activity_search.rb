#encoding: utf-8

require 'searchlight/adapters/action_view'

class ActivitySearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    Activity.order(created_at: :desc)
  end

  def search_store
    query.where(store: store)
  end
end
