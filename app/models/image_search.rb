#encoding: utf-8

require 'searchlight/adapters/action_view'

class ImageSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    Image.all
  end

  def search_store
    query.where(store: store)
  end
end
