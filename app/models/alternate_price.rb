#encoding: utf-8

class AlternatePrice < ActiveRecord::Base

  monetize :price_cents, numericality: {
    greater_than: 0
  }

  #---
  belongs_to :product, touch: true
  belongs_to :group

  #---
  def self.for(group)
    find_by(group: group)
  end

  def modifier
    group.present? && group.modifier || nil
  end

  # Markup percentage calculated for given group from their base price.
  def markup_percent(group)
    base_price = product.send(group.price_method)
    return nil if base_price.nil? || price.nil? || base_price.zero?
    100 * (price - base_price) / base_price
  end

  # Margin percentage for given group.
  def margin_percent(group)
    base_price = product.send(group.price_method)
    return nil if base_price.nil? || price.nil? || price.zero?
    100 * (price - base_price) / price
  end
end
