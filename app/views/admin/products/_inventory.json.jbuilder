product.inventory_items.online.group_by(&:inventory_id).each do |id, items|
  json.set! id do
    json.array! items, :id, :code, :available, :expires_at
  end
end
