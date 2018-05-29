json.set! :daily_value, @purchases.by_date.map { |i|
  {t: i.date, y: Money.new(i.value_sans_tax).amount}
}
json.set! :daily_units, @purchases.by_date.map { |i|
  {t: i.date, y: i.amount}
}
json.units_max @purchases.units_max
