#encoding: utf-8

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  def order_confirmation
    OrderMailer.order_confirmation(Order.first)
  end

end
