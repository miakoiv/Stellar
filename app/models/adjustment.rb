#encoding: utf-8
#
# Adjustments are modifiers affecting the price of an adjustable object.
# Anything adjustable may have an adjustment that adds amount_cents to its
# price. The attached label provides detailed information.
# If an adjustment has an associated source, it should respond to
# `description` that defines the contents of the label.
#
class Adjustment < ActiveRecord::Base

  monetize :amount_cents, allow_nil: true
  monetize :amount_sans_tax_cents, :tax_cents, :amount_with_tax_cents, disable_validation: true

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

  def amount_sans_tax_cents
    return nil if amount_cents.nil?
    if account_for_taxes? && price_includes_tax?
      amount_cents - tax_cents
    else
      amount_cents
    end
  end

  def tax_cents
    return nil if amount_cents.nil?
    if price_includes_tax?
      amount_cents * tax_rate / (tax_rate + 100)
    else
      amount_cents * tax_rate / 100
    end
  end

  def amount_with_tax_cents
    return nil if amount_cents.nil?
    if account_for_taxes? && !price_includes_tax?
      amount_cents + tax_cents
    else
      amount_cents
    end
  end

  # Adjustment amounts may be subject to tax, in which case the associated
  # adjustable will respond to #price_includes_tax?.
  def account_for_taxes?
    adjustable.respond_to?(:price_includes_tax?)
  end
end
