json.inventory_items do
  json.array! product.inventory_items, :id, :code, :available, :expires_at
end
