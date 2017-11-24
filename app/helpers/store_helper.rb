#encoding: utf-8

module StoreHelper

  def fuzzy_amount(amount)
    amount > 25 ? t('number.more_than', number: 25) : amount
  end

  def product_stock(inventory, product)
    available = product.available(inventory)
    inventory.fuzzy? ? fuzzy_amount(available) : available
  end

  def money(amount)
    return nil if amount.nil?
    humanized_money_with_symbol(amount)
  end

  def fancy_price(price)
    return nil if price.nil?
    amount = incl_tax? ? price.with_tax : price.sans_tax
    sep = amount.separator
    units, subunits = humanized_money(amount).split sep
    capture do
      concat units
      concat content_tag(:span, sep, class: 'sep')
      concat content_tag(:span, subunits, class: 'cents')
      concat currency_symbol
    end
  end

  def fancy_price_range(from, to)
    if from == to
      fancy_price(from)
    else
      capture do
        concat fancy_price(from)
        concat '–'
        concat fancy_price(to)
      end
    end
  end

  # Displays a fancy price tag with a single final price,
  # or dual special/regular prices.
  def price_tag(final_price, regular_price = nil)
    content_tag(:span, class: regular_price && 'special-price') do
      concat fancy_price(final_price)
      if regular_price
        concat content_tag(:span, class: 'regular-price') { fancy_price(regular_price) }
      end
    end
  end

  # Displays a fancy price range from two final prices.
  def price_range(from, to)
    content_tag(:span, class: 'price-range') do
      fancy_price_range(from, to)
    end
  end

  def unit_pricing_string(price, quantity, unit)
    unless quantity.zero?
      capture do
        concat price_tag(price / quantity)
        concat '/'
        concat unit
      end
    end
  end
end
