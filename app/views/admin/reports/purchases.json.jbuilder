json.data do
  json.array! @purchases.by_product do |item|
    json.product_title link_to "<strong>#{item.product_title}</strong> #{item.product_subtitle}".html_safe, admin_product_path(item.product_id)
    json.product_code item.product_code
    json.amount item.amount
    json.value_sans_tax Money.new(item.value_sans_tax).format
  end
end
json.grand_total Money.new(@purchases.grand_total_sans_tax).format
json.unit_count @purchases.unit_count
json.product_count @purchases.product_count
