#
# PromotionHandler is the parent class of different promotion handlers
# with varying business logic for how to apply the promotion on a given
# order.
#
class PromotionHandler < ApplicationRecord

  belongs_to :promotion

  monetize :default_price_cents, allow_nil: true, numericality: {greater_than: 0}
  monetize :order_total_cents, allow_nil: true, numericality: {greater_than: 0}
  monetize :items_total_cents, allow_nil: true, numericality: {greater_than: 0}

  #---
  validates :description, presence: true, on: :update

  #---
  # Flattens the given items into an array so that all amounts equal one.
  def flatten(items)
    items.to_a.map { |item|
      n = item.amount
      item.amount = 1
      [item] * n
    }.flatten
  end

  # Does the opposite of flatten, combining given items by id.
  def recombine(items)
    items.chunk(&:id).map { |id, items|
      item = items.first
      item.amount = items.count
      item
    }
  end
end
