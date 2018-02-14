json.inventory_items do
  json.array! product.inventory_items, :id, :code, :expires_at
end
