require 'csv'

namespace :products do
  desc "Catalog products having multiple categories"
  task multicategory: :environment do |task, args|

    products = Product.includes(:categories).reorder(:store_id, :code)

    csv_file = CSV.generate(
      headers: %w{code title categories},
      col_sep: ';'
    ) do |csv|
      products.find_each(batch_size: 100) do |product|
        next if product.categories.count < 2
        csv << [
          product.code,
          product.to_s,
          product.categories.order(:lft).map(&:to_s).join('|')
        ]
      end
    end
    puts csv_file
  end
end
