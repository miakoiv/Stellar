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
  delegate :group, :first_date, :last_date, to: :promotion

  belongs_to :product, required: true
  delegate :real?, to: :product
  delegate :code, :customer_code, :title, :subtitle, to: :product, prefix: true

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
  after_save :touch_product
  before_destroy :touch_product

  #---
  def description
    text = promotion.description
    return text if price_cents.nil?
    text.gsub /%/, "#{discount_percent.to_i}%"
  end

  # Calculations should happen when the linked attribute changes but only once.
  # Skip if promotion doesn't have editable prices.
  def should_calculate_price
    return false unless promotion.editable_prices?
    discount_percent_changed? && !calculated && base_price.present?
  end

  def should_calculate_discount
    return false unless promotion.editable_prices?
    price_cents_changed? && !calculated && base_price.present?
  end

  # The calculations set a flag to prevent before_validation hooks from
  # firing again as the linked attribute changes.
  def calculate_price
    self.price = base_price * (1 - discount_percent/100)
    self.calculated = true
  end

  def calculate_discount
    self.discount_percent = 100 * (base_price - price) / base_price
    self.calculated = true
  end

  # Base prices are according to the target group of the promotion.
  def base_price
    product.send(group.price_method)
  end

  def to_s
    product.to_s
  end

  private
    def touch_product
      product.touch
    end
end
