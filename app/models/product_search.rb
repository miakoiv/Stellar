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

  def search_live
    return query if empty?(options[:live])
    query.where(live: checked?(options[:live]))
  end

  # Define search methods for all searchable properties, avoiding name clashes
  # by including the property id. Finding matching products is done with
  # subselects to be able to combine multiple property searches.
  Property.searchable.each do |property|
    key = "#{property.name}_#{property.id}"
    define_method("search_#{key}") do
      query.where("EXISTS (SELECT 1 FROM product_properties WHERE product_id = products.id AND property_id = #{property.id} AND value IN (?))", send(key))
    end
  end
end
