#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderReportRowSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    OrderReportRow.joins(product: :categories)
  end

  def options
    this_month = Date.current.all_month
    super.tap do |opts|
      opts[:since_date] = raw_options[:since_date].present? ? Date.parse(raw_options[:since_date]) : this_month.first
      opts[:until_date] = raw_options[:until_date].present? ? Date.parse(raw_options[:until_date]) : this_month.last
    end
  end

  def search_order_type
    query.where(order_type: order_type)
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_store_portal_id
    query.where(store_portal_id: store_portal_id)
  end

  def search_shipping_country_code
    query.where(shipping_country_code: shipping_country_code)
  end

  def search_categories
    query.where(categories: {id: categories})
  end

  def search_product_id
    query.where(product_id: product_id)
  end

  def search_keyword
    query.where("CONCAT_WS(' ', products.code, products.customer_code, products.title, products.subtitle) LIKE ?", "%#{keyword}%")
  end

  def search_since_date
    query.where('ordered_at >= ?', since_date)
  end

  def search_until_date
    query.where('ordered_at <= ?', until_date)
  end
end
