#encoding: utf-8

require 'searchlight/adapters/action_view'

class OrderSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Order.order(completed_at: :desc)
  end

  def search_store
    query.where(store: store)
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_customer_id
    query.where(customer_id: customer_id)
  end

  def search_order_type
    query.where(order_type: order_type)
  end

  def search_status
    return query if empty?(status)
    return query unless Order.statuses.include?(status.to_sym)
    query.merge(Order.send(status))
  end

  def search_date
    query.where('DATE(completed_at) = ?', date)
  end

  def search_customer
    query.where('customer_name LIKE ?', "%#{customer}%")
  end

  def search_payment_number
    query.joins(:payments).where(payments: {number: payment_number})
  end

  def search_keyword
    query.where("CONCAT_WS(' ', customer_name, company_name, contact_person, shipping_city) LIKE ?", "%#{keyword}%")
  end
end
