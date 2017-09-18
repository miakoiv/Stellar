json.data do
  json.array!(@inventory.items) do |item|
    json.title link_to "<strong>#{item.product.title}</strong> #{item.product.subtitle}".html_safe, admin_product_path(item.product)
    json.code item.product.code
    json.on_hand item.on_hand
    json.value humanized_money(item.value)
    json.total_value humanized_money(item.total_value)
  end
end
json.total_value humanized_money(@inventory.total_value)
json.item_count @inventory.items.size
