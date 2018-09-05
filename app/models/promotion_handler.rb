#encoding: utf-8
#
# PromotionHandler is the parent class of different promotion handlers
# with varying business logic for how to apply the promotion on a given
# order.
#
class PromotionHandler < ActiveRecord::Base

  belongs_to :promotion

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
