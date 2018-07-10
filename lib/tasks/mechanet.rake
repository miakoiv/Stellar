#encoding: utf-8

require 'creek'

namespace :properties do
  desc "Import Mechanet property definitions"
  task :mechanet, [:file] => :environment do |task, args|

    # Lookup table for existing measurement units.
    units = MeasurementUnit.all.map { |u| [u.name.parameterize, u] }.to_h

    # Nuke existing properties before creating fresh records.
    store = Store.find_by name: 'Mechanet'
    store.properties.destroy_all

    # Input file has the known properties in column B,
    # where the original name becomes the external name for the property
    # before attempting to extract a measurement unit in parens, which may
    # not match.
    xlsx = Creek::Book.new args.file
    sheet = xlsx.sheets[0]
    i = 0
    sheet.rows.each do |row|
      row.each do |col, name|
        next if col.first == 'A' || col == 'B1'
        match = /\(([^)]+)\)\z/.match(name)
        unit = match && units[match[1].gsub(/\d+/, '').parameterize]
        if unit
          uname = name.sub(/\s*\([^)]+\)\z/, '')
          store.properties.create(
            name: uname,
            external_name: name,
            value_type: 'numeric',
            measurement_unit: unit,
            priority: i
          )
        else
          store.properties.create(
            name: name,
            external_name: name,
            value_type: 'string',
            priority: i
          )
        end
        i += 1
      end
    end
  end
end

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
