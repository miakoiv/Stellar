#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Order.includes(:order_type).complete.order(created_at: :desc)
  end

  def search_store_id
    query.where(store_id: store_id)
  end

  # User id restricts the search on orders that may be managed by her.
  def search_user_id
    order_types = User.find(user_id).managed_order_types
    return Order.none if order_types.empty?
    query.where(order_type_id: order_types)
  end

  def search_order_type
    query.where(order_type_id: order_type)
  end

  def search_date
    query.where('DATE(completed_at) = ?', date)
  end

  def search_customer
    query.where('customer_name LIKE ?', "%#{customer}%")
  end
end
