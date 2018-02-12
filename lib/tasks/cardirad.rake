#encoding: utf-8

require 'csv'

namespace :products do
  desc "Import Cardirad products from CSV input"
  task :cardirad, [:file] => :environment do |task, args|
    #store = Store.find_by name: 'Cardirad'
    #tax_category = store.tax_categories.first
    #store.products.destroy_all

    CSV.foreach(args.file,
      encoding: 'iso-8859-1',
      col_sep: ';',
      row_sep: "\r\r\n",
      skip_blanks: true,
      headers: true,
      header_converters: [
        lambda { |h| h.tr 'åäöÅÄÖ', 'aaoAAO'},
        :downcase,
        :symbol
      ]
    ) do |row|
      puts row.inspect
    end
  end
end
