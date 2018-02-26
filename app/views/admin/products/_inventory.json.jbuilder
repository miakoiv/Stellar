json.inventory_items do
  json.array! product.inventory_items, :id, :inventory_id, :code, :available, :expires_at
end
