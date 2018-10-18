#encoding: utf-8

require 'searchlight/adapters/action_view'

class ProductSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  # Defines a search method for a property. Using subselects
  # makes it possible to match multiple properties at the same time.
  def self.define_property_search_method(property)
    key = property.sluggify
    define_method("search_#{key}") do
      query.where('EXISTS (
        SELECT 1 FROM product_properties
        WHERE property_id = ? AND value IN (?)
          AND (product_id = products.id OR
            product_id IN (
              SELECT id FROM products p
              WHERE p.master_product_id = products.id
            )
          )
        )', property, send(key))
    end
  end

  # Defines search methods for all existing properties. When a property
  # is created or modified, call #define_property_search_method on it.
  Property.searchable.each do |property|
    define_property_search_method(property)
  end

  #---
  def base_query
    Product.includes(:categories)
  end

  def search_store
    query.where(store: store)
  end

  def search_vendor_id
    query.where(vendor_id: vendor_id)
  end

  def search_code
    query.where('products.code LIKE ? OR products.customer_code LIKE ?', "#{code}%", "#{code}%")
  end

  def search_keyword
    query.where("CONCAT_WS(' ', products.code, products.customer_code, products.title, products.subtitle) LIKE ?", "%#{keyword}%")
  end

  def search_purposes
    query.where(purpose: Product.purposes.slice(*purposes).values)
  end

  def search_inventories
    query.includes(inventory_items: :inventory).where(
      inventory_items: {inventory_id: inventories}
    )
  end

  def search_categories
    query.where(categories: {id: categories})
  end

  def search_permitted_categories
    query.where(categories: {id: permitted_categories})
  end

  def search_live
    return query if empty?(live)
    query.where(live: checked?(live))
  end

  def search_having_variants
    return query if checked?(having_variants)
    query.where(variants_count: 0)
  end

  def search_price_min
    query.where('retail_price_cents >= ?', price_min.to_money.cents)
  end

  def search_price_max
    query.where('retail_price_cents <= ?', price_max.to_money.cents)
  end

  def search_exclusions
    query.where.not(id: exclusions)
  end
end
