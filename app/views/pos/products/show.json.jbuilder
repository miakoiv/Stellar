json.extract! @product, :id, :title, :subtitle
json.partial! 'pos/products/inventory', product: @product
