#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Order.includes(:order_type, :user).complete.order(completed_at: :desc)
  end

  def search_store_id
    query.where(store_id: store_id)
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_group
    query.where(users: {group: group})
  end

  def search_order_type_id
    query.where(order_type_id: order_type_id)
  end

  def search_date
    query.where('DATE(completed_at) = ?', date)
  end

  def search_customer
    query.where('customer_name LIKE ?', "%#{customer}%")
  end

  def search_summary
    query.where("CONCAT_WS(' ', company_name, contact_person, shipping_city) LIKE ?", "%#{summary}%")
  end
end
