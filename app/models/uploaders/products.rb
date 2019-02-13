#
# Uploaders are classes that handle file uploads containing data for a
# specific model, like products. To handle an uploaded file, create an
# uploader object with the expected params and call #process on it to
# receive JSON responses to be rendered where appropriate.
#
module Uploaders

  require 'spreadsheetml'

  class Products

    def initialize(params)
      @store = Store.find(params[:store_id])
      @inventory = @store.inventories.first
      @file = params[:file]
      @code = @file.original_filename
      @response = []
    end

    def process
      unless @inventory.nil?
        if @file.content_type =~ /excel/
          process_spreadsheetml
        else
          process_csv
        end
      end
      @response
    end

    def process_spreadsheetml
      ::SpreadsheetML.new(@file.read).worksheets.each do |ws|
        ws.tables.each do |t|
          headers = t.rows.shift.cells.map { |c|
            @store.csv_headers[c.text] || c.text
          }
          t.rows.each do |r|
            row = CSV::Row.new(headers, r.cells.map(&:text))
            update_product_from(row)
          end
        end
      end

      @response
    end

    def process_csv
      headers = @store.csv_headers
      options = @store.csv_options.merge(
        header_converters: lambda { |x| headers[x] || x }
      )
      CSV.foreach @file.path, options do |row|
        update_product_from(row)
      end
    end

    def update_product_from(row)
      if product = Product.update_from_csv_row(@store, @inventory, row, @code)
        @response << product.as_json(
          only: [:code, :title, :subtitle], methods: [:formatted_price_string]
        )
      end
    end
  end
end
