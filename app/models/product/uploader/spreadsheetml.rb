module Product::Uploader

  class Spreadsheetml < Base

    require 'spreadsheetml'

    def process
      ::SpreadsheetML.new(File.open(file.path)).worksheets.each do |ws|
        ws.tables.each do |t|
          headers = t.rows.shift.cells.map { |c|
            store.csv_headers[c.text] || c.text
          }
          t.rows.each do |r|
            row = CSV::Row.new(headers, r.cells.map(&:text))
            update_from(row)
          end
        end
      end
    end
  end
end
