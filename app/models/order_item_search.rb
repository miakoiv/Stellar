#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderItemSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    OrderItem.joins(:order).merge(Order.approved)
      .reorder('orders.completed_at')
  end

  def options
    return super if raw_options[:all_time].present?
    this_month = Date.current.all_month
    super.tap do |opts|
      opts[:since_date] = date_param(raw_options[:since_date], this_month.first)
      opts[:until_date] = date_param(raw_options[:until_date], this_month.last)
    end
  end

  def search_store
    query.where(orders: {store_id: store})
  end

  def search_customer_id
    query.where(orders: {customer_id: customer_id})
  end

  def search_order_type
    query.where(orders: {order_type_id: order_type})
  end

  def search_store_portal_id
    query.where(orders: {store_portal_id: store_portal_id})
  end

  def search_shipping_country_code
    query.where(orders: {shipping_country_code: shipping_country_code})
  end

  def search_product_id
    query.where(product_id: product_id)
  end

  def search_since_date
    query.where('DATE(orders.completed_at) >= ?', since_date)
  end

  def search_until_date
    query.where('DATE(orders.completed_at) <= ?', until_date)
  end

  def search_concluded_only
    return query unless checked?(concluded_only)
    query.merge(Order.concluded)
  end
end

private
  def date_param(param, default)
    return default unless param.present?
    return param if param.is_a?(Date)
    Date.parse(param)
  end
