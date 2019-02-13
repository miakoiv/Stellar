module Admin::OrdersHelper

  def back_path_for(order)
    order_type = order.order_type
    return incoming_admin_orders_path if current_group.incoming_order_types.include?(order_type)
    return outgoing_admin_orders_path if current_group.outgoing_order_types.include?(order_type)
    admin_orders_path
  end
end
