#encoding: utf-8

require 'csv'

namespace :products do
  desc "Import Mechanet products from CSV input"
  task :mechanet, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Mechanet'
    tax_category = store.tax_categories.first
    property_map = store.property_map

    CSV.foreach(args.file,
      col_sep: ';',
      headers: true,
      header_converters: :symbol,
    ) do |row|
      product = store.products.create(
        code: row[:pnumber],
        customer_code: row[:valmistajan_koodi],
        title: row[:tuotenimi],
        subtitle: row[:description],
        overview: row[:hakukone_metakuvaus],
        trade_price: Monetize.parse(row[:ostohinta]),
        retail_price: Monetize.parse(row[:ulosmyyntihinta_]),
        available_at: Date.today,
        tax_category: tax_category
      )
      warn product.errors.inspect if product.invalid?

      property_map.each do |symbol, property|
        next unless row[symbol].present?
        product.product_properties.create(
          property: property,
          value: row[symbol]
        )
      end
    end
  end
end
