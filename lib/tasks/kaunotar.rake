namespace :kaunotar do
  desc "Update product data via Kaunotar stock gateway"
  task :update, [:store, :start_date] => :environment do |task, args|
    start_date = args.start_date || Date.yesterday
    store = Store.find_by name: args.store
    ProductUpdateViaGatewayJob.perform_now(store, start_date)
  end
end
