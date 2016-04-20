#encoding: utf-8

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  Store.all.each do |store|
    store.orders.complete.each do |order|
      define_method "order_confirmation (#{store} #{order})" do
        OrderMailer.order_confirmation(order)
      end
    end

    store.orders.includes(:order_type).where(order_types: {is_quote: true}).each do |quotation|
      define_method "quotation (#{store} #{quotation})" do
        OrderMailer.quotation(quotation)
      end
    end
  end
end
