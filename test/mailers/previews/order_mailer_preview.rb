# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  def acknowledge
    email.acknowledge(to: order.billing_recipient)
  end

  def cancellation
    email.cancellation(to: order.billing_recipient)
  end

  def conclusion
    email.conclusion(to: order.billing_recipient)
  end

  def confirmation
    email.confirmation(to: order.billing_recipient)
  end

  def notification
    email.notification(to: order.billing_recipient, items: order.order_items.first(2), pricing: false)
  end

  def processing
    email.processing(to: order.billing_recipient)
  end

  def quotation
    email.quotation(to: order.billing_recipient)
  end

  def receipt
    email.receipt(to: order.billing_recipient)
  end

  def shipment
    Messaging::Shipments.new(order.shipments.last).shipment(to: order.shipping_recipient)
  end

  private
    def order
      @order ||= Order.find(2205535)
    end

    def email
      Messaging::Orders.new(order)
    end
end
