json.set! :daily_value, @sales.by_date.map { |i|
  {t: i.date, y: Money.new(i.value_sans_tax).amount}
}
json.set! :daily_units, @sales.by_date.map { |i|
  {t: i.date, y: i.amount}
}
