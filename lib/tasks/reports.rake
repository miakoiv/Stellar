#encoding: utf-8

namespace :reports do
  desc "Generate up-to-date reports from all concluded orders"
  task generate: :environment do |task, args|
    OrderReportRow.delete_all
    Order.concluded.find_each(batch_size: 50) do |order|
      order.order_items.each do |item|
        OrderReportRow.from_order_and_item(order, item)
      end
    end
  end
end
