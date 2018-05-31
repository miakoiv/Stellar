#!/usr/bin/env ruby

require 'csv'

sheet1 = CSV.read 'sheet1.csv', col_sep: ';', headers: [:ref, :gtin, :title]
sheet2 = CSV.read 'sheet2.csv', col_sep: ';', headers: [:ref, :subtitle]
result = CSV.open 'asahi.csv', 'wb', col_sep: ';', headers: [:ref, :gtin, :title, :subtitle]

subtitles = {}
sheet2.each do |row|
  subtitles[row[:ref]] = row[:subtitle]
end

sheet1.each do |row|
  subtitle = subtitles[row[:ref]]
  title = subtitle.nil? ? row[:title] : row[:title].gsub(/\s+#{subtitle}$/, '')
  result << [row[:ref], row[:gtin], title, subtitle]
end

