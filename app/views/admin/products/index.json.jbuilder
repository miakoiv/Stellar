json.array!(@products) do |product|
  json.extract! product, :id, :brand_id, :category_id, :title
  json.url admin_product_url(product, format: :json)
end
