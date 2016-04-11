#encoding: utf-8

class AlternatePrice < ActiveRecord::Base

  monetize :retail_price_cents, numericality: {
    greater_than: 0
  }

  #---
  belongs_to :pricing_group
  belongs_to :product, touch: true

  #---
  # Price factor between retail price and this alternate price.
  def price_factor
    return nil if product.retail_price.nil? || retail_price.nil? || retail_price == 0
    retail_price / product.retail_price
  end

  # Margin percentage from trade price to this alternate price.
  def margin_percent
    return nil if product.trade_price.nil? || retail_price.nil? || retail_price == 0
    100 * (retail_price - product.trade_price) / retail_price
  end
end
