# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  def acknowledge
    email.acknowledge(to: order.customer_string)
  end

  def cancellation
    email.cancellation(to: order.customer_string)
  end

  def conclusion
    email.conclusion(to: order.customer_string)
  end

  def confirmation
    email.confirmation(to: order.customer_string)
  end

  def notification
    email.notification(to: order.customer_string, items: order.order_items.first(2), pricing: false)
  end

  def processing
    email.processing(to: order.customer_string)
  end

  def quotation
    email.quotation(to: order.customer_string)
  end

  def receipt
    email.receipt(to: order.customer_string)
  end

  def shipment
    Messaging::Shipments.new(order.shipments.last).shipment(to: order.customer_string)
  end

  private
    def order
      @order ||= Order.find(2205535)
    end

    def email
      Messaging::Orders.new(order)
    end
end
