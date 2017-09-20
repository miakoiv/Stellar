json.set! :daily_value, @sales.by_date.map { |i|
  {t: i.date, y: Money.new(i.value).amount}
}
json.set! :daily_units, @sales.by_date.map { |i|
  {t: i.date, y: i.amount}
}
json.data do
  json.array! @sales.by_product do |item|
    json.product_title link_to "<strong>#{item.product_title}</strong> #{item.product_subtitle}".html_safe, admin_product_path(item.product_id)
    json.product_code item.product_code
    json.amount item.amount
    json.subtotal_value Money.new(item.subtotal_value).format
  end
end
json.grand_total Money.new(@sales.grand_total).format
json.unit_count @sales.unit_count
json.product_count @sales.product_count
