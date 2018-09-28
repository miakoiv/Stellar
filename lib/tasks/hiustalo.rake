#encoding: utf-8

require 'csv'

namespace :products do
  desc "Import Hiustalo product stock from CSV input"
  task :hiustalo_stock, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'
    store.products.find_each(batch_size: 50) do |product|
      product.update(available_at: nil)
    end
    inventory = store.inventories.first
    inventory.inventory_items.destroy_all

    CSV.foreach(args.file,
      encoding: 'utf-8',
      col_sep: ';',
      skip_blanks: true,
      headers: true,
      header_converters: lambda { |h| h.downcase.to_sym }
    ) do |row|
      code = row[:viivakoodi2].presence || row[:viivakoodi].presence
      amount = row[:myyntivarasto].to_i
      next if code.nil? || amount <= 0
      product = store.products.find_by(code: code)
      if product.nil?
        warn "! %-20s %4.0i %s" % [code, amount, row[:nimi]]
        next
      end
      product.update(
        trade_price: row[:ostohinta].to_money,
        retail_price: row[:myyntihinta].to_money,
        available_at: Date.today
      )
      product.restock!(inventory, Date.today.to_s, nil, amount)
      puts "+ %-20s %4.0i %s" % [code, amount, product.title]
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
