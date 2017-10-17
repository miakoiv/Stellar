#encoding: utf-8

class AlternatePrice < ActiveRecord::Base

  monetize :price_cents, numericality: {
    greater_than: 0
  }

  #---
  belongs_to :product, touch: true
  belongs_to :group

  #---
  def modifier
    group.present? && group.modifier || nil
  end

  # Markup percentage from group base price to this alternate price.
  def markup_percent
    return nil if group.nil?
    base_price = product.send(group.price_method)
    return nil if base_price.nil? || price.nil? || base_price.zero?
    100 * (price - base_price) / base_price
  end

  # Margin percentage between group base price and this alternate price.
  def margin_percent
    return nil if group.nil?
    base_price = product.send(group.price_method)
    return nil if base_price.nil? || price.nil? || price.zero?
    100 * (price - base_price) / price
  end
end
