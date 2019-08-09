namespace :kaunotar do
  desc "Update Hiustalo product data via Kaunotar stock gateway"
  task :hiustalo, [:start_date] => :environment do |task, args|
    start_date = args.start_date || Date.yesterday
    store = Store.find_by name: 'Hiustalo Outlet'
    ProductUpdateViaGatewayJob.perform_now(store, start_date)
  end
end
