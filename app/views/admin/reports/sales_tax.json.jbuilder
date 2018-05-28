json.data do
  json.array! @sales.by_tax_rate do |item|
    json.tax_rate number_to_percentage item.tax_rate, precision: 0
    json.amount item.amount
    json.value_sans_tax Money.new(item.value_sans_tax).format
    json.value_tax Money.new(item.value_tax).format
    json.value_with_tax Money.new(item.value_with_tax).format
  end
end
