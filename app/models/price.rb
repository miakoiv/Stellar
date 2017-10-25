#encoding: utf-8
#
# Price is a wrapper around Money with taxation metadata and
# methods for the amount with or without tax, and the tax itself.
#
class Price
  include Comparable

  attr_accessor :amount, :tax_included, :tax_rate

  #---
  def initialize(attributes = {})
    @amount = attributes[:amount]
    @tax_included = attributes[:tax_included]
    @tax_rate = attributes[:tax_rate]
  end

  # All-purpose zero, compatible with any taxation.
  def self.zero
    new(amount: Money.zero, tax_included: nil, tax_rate: nil)
  end

  #---
  def sans_tax
    return nil if amount.nil?
    tax_included ? amount - tax : amount
  end

  def with_tax
    return nil if amount.nil?
    tax_included ? amount : amount + tax
  end

  def tax
    return nil if amount.nil?
    if tax_included
      amount * tax_rate / (tax_rate + 100)
    else
      amount * tax_rate / 100
    end
  end

  def zero?
    amount.zero?
  end

  def modify!(percent)
    self.amount += amount * percent / 100 unless amount.nil? || zero?
    self
  end

  def <=>(other)
    sans_tax <=> other.sans_tax
  end

  # NOTE: Arithmetic operations are only meaningful between prices
  # with the exact same taxation.
  def +(other)
    dup.tap { |this| this.amount += other.amount }
  end

  def *(x)
    return Price.zero if amount.nil?
    dup.tap { |this| this.amount *= x }
  end

  def /(x)
    raise ZeroDivisionError if x.zero?
    return Price.zero if amount.nil?
    dup.tap { |this| this.amount /= x }
  end
end
