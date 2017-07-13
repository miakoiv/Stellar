json.array!(@products) do |product|
  json.extract! product, :id, :code, :customer_code, :title, :subtitle
  json.url admin_product_url(product, format: :json)
  json.icon_image product.cover_image.url(:icon) if product.cover_image.present?
end
