require 'csv'

namespace :products do
  desc "Import product data from spreadsheet"
  task :import_spreadsheet, [:store, :file] => :environment do |task, args|
    store = Store.find_by name: args.store
    property_ml = store.properties
      .joins(:measurement_unit)
      .find_by(measurement_units: {name: 'ml'})

    ods = Roo::Spreadsheet.open args.file
    ods.each_with_pagename do |name, sheet|
      sheet.parse(
        ean: /\AEAN/i,
        title: /NIMI/i,
        description: /KUVAUS/i,
        brand: /TOIMITTAJA/i,
        ml: /\Aml/,
        trade_price: /OSTOHINTA/i,
        retail_price: /MYYNTIHINTA/i,
      ).each do |row|
        code = row[:ean]
        next unless code.present?
        product = store.products.find_by(code: code)
        if product.nil?
          warn "err %s not found" % code
          next
        end
        product.update(
          title: row[:title],
          overview: row[:description],
          trade_price: row[:trade_price].to_money,
          retail_price: row[:retail_price].to_money
        )
        tag = store.tags.find_or_create_by(name: row[:brand])
        product.tags << tag unless product.tags.include?(tag)

        prop = product.product_properties
          .find_or_initialize_by(property: property_ml)
        prop.value = row[:ml].to_s
        prop.save
        puts "[p] %-15s %s" % [code, row[:title]]
      end
    end
  end

  desc "Merge existing products with conflicting EAN/UPC codes"
  task :ean2upc, [:store] => :environment do |task, args|
    store = Store.find_by name: args.store
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
