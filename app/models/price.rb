#encoding: utf-8
#
# Price is a wrapper around Money with taxation metadata and
# methods for the amount with or without tax, and the tax itself.
#
class Price
  include Comparable

  DEFAULT_TAX_RATE = 24.0

  attr_accessor :amount, :tax_included, :tax_rate

  #---
  def initialize(amount, tax_included = true, tax_rate = DEFAULT_TAX_RATE)
    @amount       = amount
    @tax_included = tax_included
    @tax_rate     = tax_rate
  end

  # All-purpose zero, compatible with any taxation.
  def self.zero
    new(Money.zero)
  end

  #---
  def sans_tax
    return nil if nil?
    tax_included ? amount - tax : amount
  end

  def with_tax
    return nil if nil?
    tax_included ? amount : amount + tax
  end

  def tax
    return nil if nil?
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
    self.amount += amount * percent / 100 unless nil? || zero?
    self
  end

  def nil?
    amount.nil?
  end

  def <=>(other)
    sans_tax <=> other.sans_tax
  end

  # NOTE: Arithmetic operations are only meaningful between prices
  # with the exact same taxation.
  def +(other)
    return Price.zero if nil?
    self.class.new(amount + other.amount, tax_included, tax_rate)
  end

  def *(x)
    return Price.zero if nil?
    self.class.new(amount * x, tax_included, tax_rate)
  end

  def /(x)
    raise ZeroDivisionError if x.zero?
    return Price.zero if nil?
    self.class.new(amount / x, tax_included, tax_rate)
  end

  def to_s
    amount.to_s
  end
end
