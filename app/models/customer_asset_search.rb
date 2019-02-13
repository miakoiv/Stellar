require 'searchlight/adapters/action_view'

class CustomerAssetSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  #---
  def base_query
    CustomerAsset.includes(:product).order('products.title', 'products.subtitle')
  end

  def search_store
    query.where(store: store)
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_product_id
    query.where(product_id: product_id)
  end
end
