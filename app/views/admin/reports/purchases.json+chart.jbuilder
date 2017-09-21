json.set! :daily_value, @purchases.by_date.map { |i|
  {t: i.date, y: Money.new(i.value).amount}
}
json.set! :daily_units, @purchases.by_date.map { |i|
  {t: i.date, y: i.amount}
}
