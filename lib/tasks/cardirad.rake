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
      headers: [:ref, :gtin, :title, :subtitle],
    ) do |row|
      product = store.products.create(
        code: row[:ref],
        customer_code: row[:gtin],
        title: row[:title],
        subtitle: row[:subtitle],
        available_at: Date.today,
        tax_category: tax_category,
      )
      puts product
    end
  end
end
