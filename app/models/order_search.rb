require 'searchlight/adapters/action_view'

class OrderSearch < Searchlight::Search

  include Searchlight::Adapters::ActionView

  def base_query
    Order.order(completed_at: :desc)
  end

  def search_store
    query.where(store: store)
  end

  def search_billing_group
    query.where(billing_group: Group.find(billing_group).self_and_descendants)
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_order_type
    query.where(order_type: order_type)
  end

  def search_status
    return query if empty?(status)
    return query unless Order.statuses.include?(status.to_sym)
    query.merge(Order.send(status))
  end

  def search_since_date
    query.where('DATE(completed_at) >= ?', since_date)
  end

  def search_until_date
    query.where('DATE(completed_at) <= ?', until_date)
  end

  def search_number
    query.left_outer_joins(:payments, :shipments)
      .where(
        Order.arel_table[:number].eq(number)
        .or(Payment.arel_table[:number].eq(number))
        .or(Shipment.arel_table[:id].eq(number))
      )
  end

  def search_keyword
    query.joins(:shipping_address).where("CONCAT_WS(' ', addresses.name, addresses.company, addresses.address1, addresses.address2, addresses.city) LIKE ?", "%#{keyword}%")
  end
end
