#encoding: utf-8

# Preview all emails at http://localhost:3000/rails/mailers/order_mailer

class OrderMailerPreview < ActionMailer::Preview

  Store.all.each do |store|
    store.orders.complete.last(10).each do |order|
      if order.has_payment?
        define_method "#{store} #{order} receipt" do
          order.email(:receipt, order.customer_string)
        end
        define_method "#{store} #{order} processing" do
          order.email(:processing, order.customer_string, nil, bcc: false)
        end
      else
        define_method "#{store} #{order} acknowledge" do
          order.email(:acknowledge, order.customer_string)
        end
        define_method "#{store} #{order} confirmation" do
          order.email(:confirmation, order.customer_string, nil, bcc: false)
        end
      end
      define_method "#{store} #{order} shipment" do
        order.email(:shipment, order.customer_string, nil, bcc: false)
      end
      define_method "#{store} #{order} cancellation" do
        order.email(:cancellation, order.customer_string)
      end
      order.items_by_vendor.each do |vendor, items|
        vendor.notified_users.each do |user|
          define_method "#{store} #{order} notify vendor #{user.name}" do
            order.email(:notification, user.to_s, items, bcc: false, pricing: false)
          end
        end
      end
    end
  end
end
