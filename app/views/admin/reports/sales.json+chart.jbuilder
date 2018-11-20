json.set! :temporal_value, @sales.temporal_data.map { |i|
  {t: i.datum, y: Money.new(i.value_sans_tax).amount}
}
json.set! :temporal_units, @sales.temporal_data.map { |i|
  {t: i.datum, y: i.amount}
}
json.units_max @sales.units_max
