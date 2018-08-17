#encoding: utf-8

require 'csv'

namespace :products do
  desc "Import Cardirad products from CSV input"
  task :cardirad, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Cardirad Finland'
    tax_category = store.tax_categories.first

    CSV.foreach(args.file,
      encoding: 'utf-8',
      col_sep: ';',
      skip_blanks: true,
      headers: [:ref, :gtin, :title, :subtitle, :trade_price, :retail_price],
    ) do |row|
      product = store.products.create(
        code: row[:ref],
        customer_code: row[:gtin],
        title: row[:title],
        subtitle: row[:subtitle],
        trade_price: row[:trade_price].to_money,
        retail_price: row[:retail_price].to_money,
        available_at: Date.today,
        tax_category: tax_category,
      )
      puts product
    end
  end
end

namespace :categories do
  desc "Import Cardirad category data from CSV input"
  task :cardirad, [:file] => :environment do |task, args|
    store = Store.find_by name: 'Cardirad Finland'

    CSV.foreach(args.file,
      encoding: 'utf-8',
      col_sep: ';',
      skip_blanks: true,
      headers: true,
      header_converters: lambda { |h| h.parameterize('_').to_sym }
    ) do |row|
      categories = row
        .to_h
        .slice(:segment, :product_group, :product_family, :product_name)
        .values
        .compact
        .map(&:strip)
      parent = nil
      this = nil
      categories.each do |name|
        this = store.categories
          .create_with(product_scope: :alphabetical)
          .find_or_create_by!(parent: parent, name: name)
        parent = this
      end
      product = store.products.find_by(code: row[:code])
      product.update!(categories: [this]) if product.present?
    end
  end
end

namespace :inventory do
  desc "Import Cardirad inventory data from CSV input"
  task :cardirad, [:code, :file] => :environment do |task, args|
    store = Store.find_by name: 'Cardirad Finland'
    inventory = store.inventories.find_by(inventory_code: args.code)
    inventory.inventory_items.destroy_all

    CSV.foreach(args.file,
      encoding: 'utf-8',
      col_sep: ';',
      skip_blanks: true,
      headers: [:title, :gtin, :lot, :expires, :amount]
    ) do |row|
      product = store.products.find_by(customer_code: row[:gtin])
      if product.present?
        lot_code = row[:lot]
        expires_at = row[:expires]
        amount = row[:amount].to_i
        next if amount < 1
        product.restock!(inventory, lot_code, expires_at, amount)
        puts "+ #{product} LOT #{lot_code} ##{amount}"
      else
        puts "! #{row[:title]} GTIN #{row[:gtin]}"
      end
    end
  end
end
