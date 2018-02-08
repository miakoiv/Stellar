json.inventory_items do
  json.array! product.inventory_items, :id, :code, :expires_at
end
json.inventory_entries do
  product.inventory_items.each do |item|
    json.set! item.id, item.inventory_entries.with_serial_number do |entry|
      json.id entry.id
      json.serial_number entry.serial_number
    end
  end
end
