#encoding: utf-8

require 'searchlight/adapters/action_view'

class ProductSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Product.includes(:categories).order(:title, :subtitle)
  end

  def search_store_id
    query.where(store_id: store_id)
  end

  def search_code
    query.where('products.code LIKE ?', "#{code}%")
  end

  def search_keyword
    query.where("CONCAT_WS(' ', products.title, products.subtitle) LIKE ?", "%#{keyword}%")
  end

  def search_categories
    query.where(categories: {id: categories})
  end

  def search_search_tags
    query.where('MATCH (search_tags) AGAINST (? IN BOOLEAN MODE)', search_tags)
  end

  def search_live
    return query if empty?(options[:live])
    query.where(live: checked?(options[:live]))
  end
end
