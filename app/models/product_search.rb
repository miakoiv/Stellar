#encoding: utf-8

require 'searchlight/adapters/action_view'

class ProductSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  # Defines a search method for a property. Using subselects
  # makes it possible to match multiple properties at the same time.
  def self.define_search_method(property)
    key = property.sluggify
    define_method("search_#{key}") do
      query.where("EXISTS (SELECT 1 FROM product_properties WHERE product_id = products.id AND property_id = #{property.id} AND value IN (?))", send(key))
    end
  end

  # Defines search methods for all existing properties. When a property
  # is created or modified, call #define_search_method on it.
  Property.searchable.each do |property|
    define_search_method(property)
  end

  #---
  def base_query
    Product.order(:title, :subtitle)
  end

  def search_store_id
    query.where(store_id: store_id)
  end

  def search_code
    query.where('code LIKE ?', "#{code}%")
  end

  def search_keyword
    query.where("CONCAT_WS(' ', code, title, subtitle) LIKE ?", "%#{keyword}%")
  end

  def search_categories
    query.where(categories: {id: categories})
  end

  def search_live
    return query if empty?(live)
    query.where(live: checked?(live))
  end
end
