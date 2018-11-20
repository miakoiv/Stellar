json.set! :temporal_value, @purchases.temporal_data.map { |i|
  {t: i.datum, y: Money.new(i.value_sans_tax).amount}
}
json.set! :temporal_units, @purchases.temporal_data.map { |i|
  {t: i.datum, y: i.amount}
}
json.units_max @purchases.units_max
