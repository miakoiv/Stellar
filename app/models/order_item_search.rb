#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderItemSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    OrderItem.joins(:order).merge(Order.approved)
      .pending.order('order_items.created_at')
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

  def search_product_id
    query.where(product_id: product_id)
  end
end
