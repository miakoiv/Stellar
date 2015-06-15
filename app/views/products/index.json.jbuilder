json.array!(@products) do |product|
  json.extract! product, :id, :brand_id, :category_id, :name
  json.url product_url(product, format: :json)
end
