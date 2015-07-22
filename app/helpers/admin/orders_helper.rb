#encoding: utf-8

module Admin::OrdersHelper

  # Returns the name of the tab order resides on in order index.
  def orders_tab(order)
    order.approval ? 'approved' : ''
  end
end
