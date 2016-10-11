#encoding: utf-8

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  Store.all.each do |store|
    store.orders.complete.each do |order|
      define_method "order_confirmation (#{store} #{order})" do
        OrderMailer.order_confirmation(order)
      end
      define_method "order_notification (#{store} #{order})" do
        OrderMailer.order_notification(order)
      end
      order.items_by_vendor.each do |vendor, items|
        define_method "vendor_notification (#{store} #{order} #{vendor.name})" do
          OrderMailer.vendor_notification(order, vendor, items)
        end
      end
    end

    store.orders.cancelled.each do |order|
      define_method "order_cancellation (#{store} #{order})" do
        OrderMailer.order_cancellation(order)
      end
    end

    store.orders.joins(:order_type).where(order_types: {is_quote: true}).each do |quotation|
      define_method "quotation (#{store} #{quotation})" do
        OrderMailer.quotation(quotation)
      end
    end
  end
end
