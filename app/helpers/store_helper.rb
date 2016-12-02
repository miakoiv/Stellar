#encoding: utf-8

module StoreHelper

  def fuzzy_amount(amount)
    amount > 25 ? t('number.more_than', number: 25) : amount
  end

  def unit_price_string(price, unit)
    "#{humanized_money_with_symbol price} / #{unit}"
  end

  def humanized_money_range(range)
    min, max = range
    if min == max
      humanized_money_with_symbol min
    else
      "#{humanized_money_with_symbol min} – #{humanized_money_with_symbol max}"
    end
  end

  def property_string(product_properties)
    product_properties.map { |pp|
      content_tag(:span, pp.value, class: 'label label-default')
    }.join(' ').html_safe
  end
end
