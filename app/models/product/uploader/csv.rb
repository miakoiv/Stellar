module Product::Uploader

  class Csv < Base

    def process
      response = []
      headers = store.csv_headers
      options = store.csv_options.merge(
        header_converters: lambda { |x| headers[x] || x }
      )
      CSV.foreach file.path, options do |row|
        if json = update_from(row)
          response << json
        end
      end
      response
    end
  end
end
