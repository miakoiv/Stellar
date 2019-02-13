# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  [:receipt, :acknowledge, :processing, :confirmation, :shipment, :notification, :cancellation, :quotation].each do |type|
    define_method type do
      order = Order.concluded.last
      to = order.customer_string
      options = {bcc: true, pricing: true}
      OrderMailer.send(type, order, to, nil, options)
    end
  end
end
