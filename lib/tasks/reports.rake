namespace :reports do
  desc "Generate up-to-date reports from all concluded orders"
  task generate: :environment do |task, args|
    OrderReportRow.delete_all
    Order.concluded.find_each(batch_size: 50) do |order|
      OrderReportRow.create_from(order)
    end
  end
end
