json.array!(@products) do |product|
  json.extract! product, :id, :code, :customer_code, :title, :subtitle
  json.icon_image_url product.icon_image_url
end
