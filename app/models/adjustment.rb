#encoding: utf-8
#
# Adjustments are modifiers affecting the price of an adjustable object.
# Anything adjustable may have an adjustment that adds its amount to
# the price of the adjustable. Tax rate and inclusion of the adjustment
# is regarded identical to the adjustable.
# The attached label provides detailed information. If an adjustment has
# an associated source, it should respond to `description` that defines
# the contents of the label.
#
class Adjustment < ActiveRecord::Base

  monetize :amount_cents, allow_nil: true

  #---
  belongs_to :adjustable, polymorphic: true
  belongs_to :source, polymorphic: true

  scope :credit, -> { where('amount_cents <= ?', 0) }
  scope :charge, -> { where('amount_cents > ?', 0) }

  #---
  delegate :price_includes_tax?, :tax_rate, to: :adjustable

  #---
  def credit?
    amount_cents.nil? || amount_cents < 0
  end

  def charge?
    amount_cents.present? && amount_cents > 0
  end

  def amount_sans_tax
    account_for_taxes? ? amount_as_price.sans_tax : amount_as_price
  end

  def tax
    account_for_taxes? ? amount_as_price.tax : Price.zero
  end

  def amount_with_tax
    account_for_taxes? ? amount_as_price.with_tax : amount_as_price
  end

  # Adjustment amounts may be subject to tax, in which case the associated
  # adjustable will respond to #price_includes_tax?.
  def account_for_taxes?
    adjustable.respond_to?(:price_includes_tax?)
  end

  private
    def amount_as_price
      @amount_as_price ||= Price.new(amount, price_includes_tax?, tax_rate)
    end
end
