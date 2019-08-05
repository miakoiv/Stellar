namespace :kaunotar do
  desc "Update Hiustalo product data via Kaunotar stock gateway"
  task hiustalo: :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'
    ProductUpdateViaGatewayJob.perform_now(store, Date.yesterday)
  end
end
