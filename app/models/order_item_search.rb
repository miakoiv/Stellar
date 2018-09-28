#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderItemSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    OrderItem.joins(:order).merge(Order.pending).order('order_items.created_at')
  end

  def search_store
    query.where(orders: {store_id: store})
  end
end
