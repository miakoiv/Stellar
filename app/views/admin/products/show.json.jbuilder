json.extract! @product, :id, :code, :customer_code, :title, :subtitle
json.url admin_product_url(@product, format: :json)
json.icon_image_url @product.icon_image_url
