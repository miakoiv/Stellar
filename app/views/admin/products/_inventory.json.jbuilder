inventory_items = product.inventory_items
filtered = params[:offline] ? inventory_items : inventory_items.online
filtered.group_by(&:inventory_id).each do |id, items|
  json.set! id do
    json.array! items, :id, :code, :available, :expires_at
  end
end
