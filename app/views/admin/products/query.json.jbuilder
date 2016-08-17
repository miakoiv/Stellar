json.array!(@products) do |product|
  json.extract! product, :id, :code, :customer_code, :title, :subtitle
  json.url admin_product_url(product, format: :json)
  json.image_html image_variant_tag(product.cover_image, :thumbnail)
end
