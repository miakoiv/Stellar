#encoding: utf-8
#
# PromotedItem links a product to a promotion and optionally specifies
# a discount percent and price. Both are stored to allow calculation of
# the price before discount, since product pricing is subject to change.
#
class PromotedItem < ActiveRecord::Base

  monetize :price_cents, allow_nil: true

  attr_accessor :calculated

  #---
  belongs_to :promotion, touch: true
  belongs_to :product

  #---
  validates :discount_percent,
    numericality: {
      allow_nil: true,
      only_integer: false,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    }, on: :update

  before_validation :calculate_price, if: :should_calculate_price
  before_validation :calculate_discount, if: :should_calculate_discount
  after_save :reset_product
  after_destroy :reset_product

  #---
  def description
    text = promotion.description
    return text if price_cents.nil?
    text.gsub /%/, "#{discount_percent.to_i}%"
  end

  # Calculations should happen when the linked attribute changes but only once.
  def should_calculate_price
    discount_percent_changed? && !calculated
  end

  def should_calculate_discount
    price_cents_changed? && !calculated
  end

  # The calculations set a flag to prevent before_validation hooks from
  # firing again as the linked attribute changes.
  def calculate_price
    self.price_cents = product.retail_price_cents * (1 - discount_percent/100)
    self.calculated = true
  end

  def calculate_discount
    self.discount_percent = 100 * (product.retail_price_cents - price_cents).to_f / product.retail_price_cents
    self.calculated = true
  end

  private
    def reset_product
      product.reset_promoted_price!
    end
end
