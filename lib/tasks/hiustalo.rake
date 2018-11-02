#encoding: utf-8

require 'csv'

namespace :products do
  desc "Import Hiustalo product data"
  task :hiustalo, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'
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
        next unless row[:ean].present?
        code = row[:ean].to_s.rjust(13, '0')
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
end

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

namespace :images do
  desc "Import Hiustalo image files"
  task :hiustalo, [:path, :file] => :environment do |task, args|
    store = Store.find_by name: 'Hiustalo Outlet'

    # Filenames begin with a 13-digit product code.
    file = File.absolute_path(args.file, args.path)
    code = /\A\d+/.match(args.file).to_s

    # Copy the file into a tempfile to ensure paperclip can unlink it.
    tmp = Tempfile.new(code)
    tmp.write(File.read(file))

    # Store image by filename, whether it will be used or not.
    image = store.images.find_or_initialize_by(attachment_file_name: args.file)
    image.attachment = tmp
    image.save!
    puts "[i] %s" % args.file

    # Find matching product and replace its cover picture.
    product = store.products.find_by code: code
    if product
      pictures = product.pictures.presentational
      pictures.destroy_all
      pictures.create(image: image)
      puts "[p] %s %s" % [code, product]
    else
      warn "err %s not found" % code
    end
  end
end
