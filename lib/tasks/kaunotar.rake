namespace :kaunotar do
  desc "Update Hiustalo product data via Kaunotar stock gateway"
  task :hiustalo, [:start_date] => :environment do |task, args|
    start_date = args.start_date || Date.yesterday
    store = Store.find_by name: 'Hiustalo Outlet'
    ProductUpdateViaGatewayJob.perform_now(store, start_date)
  end

  desc "Merge existing products with conflicting EAN/UPC codes"
  task ean2upc: :environment do |task|
    store = Store.find_by name: 'Hiustalo Outlet'
    p = Product.arel_table
    upcs = store.products.where(
      Arel::Nodes::NamedFunction.new('LENGTH', [p[:code]]).eq(12)
    )
    upcs.each do |upc|
      ean = store.products.find_by(code: '0' + upc[:code])
      next if ean.nil?
      upc.update_columns(
        description: upc.description.presence || ean.description,
        overview: upc.overview.presence || ean.overview
      )
      puts "%13s: %s %s" % [ean.code, ean.title, ean.subtitle]
      ean.destroy
    end
  end
end
