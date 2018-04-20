#encoding: utf-8

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  [:receipt, :acknowledge, :processing, :confirmation, :shipment, :notification, :cancellation].each do |type|
    define_method type do
      order = Order.concluded.sample
      to = order.customer_string
      options = {bcc: true, pricing: true}
      OrderMailer.send(type, order, to, nil, options)
    end
  end
end
