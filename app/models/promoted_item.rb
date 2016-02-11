#encoding: utf-8
#
# PromotedItem links a product to a promotion and optionally specifies
# a discount percent and price. Both are stored to allow calculation of
# the price before discount, since product pricing is subject to change.
#
class PromotedItem < ActiveRecord::Base

  monetize :price_cents, allow_nil: true
  #---

  belongs_to :promotion, touch: true
  belongs_to :product

  validates :discount_percent,
    numericality: {
      allow_nil: true,
      only_integer: false,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    }, on: :update

  #---
  # Recalculations to keep discount percent and price synchronized.
  def recalculate
    if changes[:discount_percent].present?
      self.price = product.retail_price * (1 - discount_percent/100)
    elsif changes[:price_cents].present?
      self.discount_percent = 100 * (product.retail_price_cents - price_cents).to_f / product.retail_price_cents
    end
  end
  before_validation :recalculate
end
