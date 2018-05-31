#!/usr/bin/env ruby

require 'csv'

# Headers in sample data after header conversion:
# :nimi               product title
# :muutettu           modification time
# :mrtuote            inventory amount
# :mr                 <ignored>
# :viimeinen_kyttpiv  expiration date
# :barcode_tuote      GTIN
# :lot                lot code
# :varasto            inventory name

input = CSV.read ARGV.shift,
  col_sep: ';',
  row_sep: "\r\n",
  headers: true,
  header_converters: :symbol,
  skip_blanks: true,
  encoding: 'ISO-8859-1'

output = CSV.new $stdout,
  col_sep: ';',
  headers: [:title, :gtin, :lot, :expires, :amount]

stock = {}
input.each do |row|

  gtin = row[:barcode_tuote]
  lot = row[:lot].sub(/(.+)91\d{4,}\Z/, '\1')
  expires = Date.strptime(row[:viimeinen_kyttpiv], '%d.%m.%Y')
  amount = row[:mrtuote].to_i

  key = [gtin, lot]
  warn "+#{gtin}|#{lot}" if stock[key].nil?
  stock[key] ||= {
    title: row[:nimi],
    gtin: gtin,
    lot: lot,
    expires: expires,
    amount: 0
  }
  stock[key][:amount] += amount
  warn " #{gtin}|#{lot} #{amount}"
end

stock.values.each do |row|
  output << row
end
