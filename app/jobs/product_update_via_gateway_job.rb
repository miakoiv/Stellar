class ProductUpdateViaGatewayJob < ApplicationJob
  queue_as :default

  # Performs a mass product update through the stock gateway
  # the given store uses. Optionally specify the last successful
  # run as `timestamp` to skip items already seen.
  def perform(store, timestamp = Time.at(0))
    gateway = store.stock_gateway_singleton
    tax_category = store.tax_categories.first
    t = Product.arel_table
    gateway.products.each do |item|
      next if item[:code].blank?
      product = store.products.find_by(
        t[:customer_code].eq(item[:customer_code]).or(
          t[:code].eq(item[:code])
        )
      )
      product ||= store.products.create!(
        code: item[:code],
        customer_code: item[:customer_code],
        title: item[:title],
        tax_category: tax_category
      )
      product.update!(
        customer_code: item[:customer_code],
        retail_price: item[:retail_price]
      )
    end
  end
end
