json.data do
  json.array! @inventory.with_subtotals do |item|
    json.product_title link_to "<strong>#{item.product_title}</strong> #{item.product_subtitle}".html_safe, admin_product_path(item.product_id)
    json.product_code item.product_code
    json.on_hand item.on_hand
    json.unit_value Money.new(item.unit_value).format
    json.subtotal_value Money.new(item.subtotal_value).format
  end
end
json.grand_total Money.new(@inventory.grand_total).format
json.product_count @inventory.product_count
