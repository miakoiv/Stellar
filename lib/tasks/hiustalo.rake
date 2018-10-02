#encoding: utf-8

require 'csv'

namespace :products do
  desc "Import Hiustalo product stock from CSV input"
  task :hiustalo_stock, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'
    inventory = store.inventories.first
    tax_category = store.tax_categories.first

    CSV.foreach(args.file,
      encoding: 'utf-8',
      col_sep: ';',
      skip_blanks: true,
      headers: true,
      header_converters: lambda { |h| h.downcase.to_sym }
    ) do |row|
      ean = row[:viivakoodi2].presence || row[:viivakoodi].presence
      next if ean.nil?
      code = ean.rjust(13, '0')
      amount = row[:myyntivarasto].to_i
      category = row[:toimittaja].presence &&
        store.categories.find_by(
          'slug LIKE ?', "#{row[:toimittaja].parameterize.remove /\W/}%"
        )
      value = row[:pakkauskoko]
      property = value.present? && row[:yksikkö].present? &&
        store.properties.joins(:measurement_unit).find_by(
          measurement_units: {name: row[:yksikkö]}
        )
      product = store.products
        .create_with(
          title: row[:nimi],
          categories: [category].compact,
          tax_category: tax_category
        ).find_or_create_by(code: code)
      product.update(
        trade_price: row[:ostohinta].to_money,
        retail_price: row[:myyntihinta].to_money,
        available_at: Date.today
      )
      if property.present?
        product.product_properties
          .create_with(value: value).find_or_create_by(property: property)
      end
      if amount > 0
        product.restock!(inventory, Date.today.to_s, nil, amount)
      end
      puts "%s %-15s %s" % [
        product.new_record? ? '+' : ' ',
        code,
        product.title
      ]
    end
  end
end

namespace :products do
  desc "Import Hiustalo products from CSV input"
  task :hiustalo, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'
    tax_category = store.tax_categories.first
    brand_property = store.properties.find_by(name: 'Tuotemerkki')
    store.products.destroy_all

    CSV.foreach(args.file,
      col_sep: ';',
      headers: true,
    ) do |row|
      category_slug = (row['Kategoriapolku'] || '').split('/').last
      product = store.products.create(
        code: row['EAN-koodi'],
        customer_code: row['SKU'],
        title: row['Nimi'],
        retail_price: Monetize.parse(row['Tuotteen hinta']),
        categories: [
          store.categories.find_by(slug: category_slug),
          store.categories.find_by(name: row['Tuotemerkki'])
        ].compact,
        tax_category: tax_category
      )
      raise RuntimeError.new(row['EAN-koodi']) unless product.valid?
      if row['Tuotemerkki'].present?
        product.product_properties.create(
          property: brand_property,
          value: row['Tuotemerkki']
        )
      end
    end
  end
end

namespace :products do
  desc "Import Hiustalo product data and images from CSV input"
  task :hiustalo_data, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'

    CSV.foreach(args.file,
      col_sep: ';',
      headers: true,
    ) do |row|
      customer_code = 'CMH-' + row['Tuote-ID']
      overview = row['Tuotekuvaus'].gsub(/\\\n/, '')
      image_urls = row['Tuotekuvat'].split(',')

      product = store.products.find_by customer_code: customer_code
      next if product.nil?
      product.images.destroy_all

      product.update(overview: overview)
      image_urls.each do |url|
        begin
          product.images.create!(attachment: URI.parse(url))
        rescue
          $stderr.print $!
        end
      end
    end
  end
end
