#encoding: utf-8

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  def order_confirmation
    OrderMailer.order_confirmation(Order.complete.first)
  end

  def quotation
    OrderMailer.quotation(Order.includes(:order_type).where(order_types: {is_quote: true}).first)
  end
end
