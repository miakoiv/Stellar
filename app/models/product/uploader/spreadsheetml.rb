module Product::Uploader

  class Spreadsheetml < Base

    require 'spreadsheetml'

    def process
      response = []
      ::SpreadsheetML.new(file.read).worksheets.each do |ws|
        ws.tables.each do |t|
          headers = t.rows.shift.cells.map { |c|
            store.csv_headers[c.text] || c.text
          }
          t.rows.each do |r|
            row = CSV::Row.new(headers, r.cells.map(&:text))
            if json = update_from(row)
              response << json
            end
          end
        end
      end
      response
    end
  end
end
