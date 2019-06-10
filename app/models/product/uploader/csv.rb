module Product::Uploader

  class Csv < Base

    def process
      headers = store.csv_headers
      options = store.csv_options.merge(
        header_converters: lambda { |x| headers[x] || x }
      )
      CSV.foreach file.path, options do |row|
        update_from(row)
      end
    end
  end
end
