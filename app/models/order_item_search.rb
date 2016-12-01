#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderItemSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    OrderItem.joins(:order).merge(Order.concluded)
      .reorder('orders.completed_at DESC')
  end

  def options
    this_month = Date.current.all_month
    super.tap do |opts|
      opts[:since_date] = raw_options[:since_date].present? ? Date.parse(raw_options[:since_date]) : this_month.first
      opts[:until_date] = raw_options[:until_date].present? ? Date.parse(raw_options[:until_date]) : this_month.last
    end
  end

  def search_store_id
    query.where(orders: {store_id: store_id})
  end

  def search_order_type_id
    query.where(orders: {order_type_id: order_type_id})
  end

  def search_since_date
    query.where('DATE(orders.completed_at) >= ?', since_date)
  end

  def search_until_date
    query.where('DATE(orders.completed_at) <= ?', until_date)
  end

  def search_shipping_country_code
    query.where(orders: {shipping_country_code: shipping_country_code})
  end
end
