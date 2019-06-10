module Product::Uploader

  class Xml < Base

    require 'nokogiri'

    def process
      tax_categories = store.tax_categories.group_by { |t| t.rate.to_i.to_s }

      xml = File.open(file.path) { |f| Nokogiri::XML(f) }
      xml.xpath('//product').each do |node|
        code = node['id'].presence || next
        tax_rate = node.at('vatpercent')&.content || next
        tax_category = tax_categories.has_key?(tax_rate) && tax_categories[tax_rate].first || next
        title = node.at('name1')&.content
        retail_price = node.at('retailprice')&.content
        product = store.products.find_or_initialize_by(code: code).tap do |p|
          p.tax_category = tax_category
          p.title ||= title
          p.retail_price = retail_price.to_money
        end
        begin
          product.save!
        rescue StandardError => e
          log_error(product)
        end
      end
    end
  end
end
