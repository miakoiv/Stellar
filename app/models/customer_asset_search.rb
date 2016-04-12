#encoding: utf-8

require 'searchlight/adapters/action_view'

class CustomerAssetSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    CustomerAsset.includes(:product).order('products.title', 'products.subtitle')
  end

  def search_store_id
    query.where(store_id: store_id)
  end
end
