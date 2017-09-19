#encoding: utf-8

module StoreHelper

  def fuzzy_amount(amount)
    amount > 25 ? t('number.more_than', number: 25) : amount
  end

  def unit_price_string(price, unit)
    "#{price_tag price} / #{unit}".html_safe
  end

  def price_tag(price)
    return nil if price.nil?
    sep = price.separator
    units, subunits = humanized_money(price).split sep
    "#{units}#{content_tag(:span, sep, class: 'sep')}#{content_tag(:span, subunits, class: 'cents')}#{currency_symbol}".html_safe
  end

  def price_range(range)
    min, max = range
    if min == max
      price_tag min
    else
      "#{price_tag min}–#{price_tag max}".html_safe
    end
  end

  def property_string(product_properties)
    product_properties.map { |pp|
      content_tag(:span, pp.value, class: 'label label-default')
    }.join(' ').html_safe
  end
end
