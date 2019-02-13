#
# Adjustments are modifiers affecting the price of an adjustable object.
# Anything adjustable may have an adjustment that adds its amount to
# the price of the adjustable. The adjustable must respond to methods
# #tax_rate and #price_includes_tax? so that the adjustable can return
# its amount with or without tax.
# The attached label provides detailed information. If an adjustment has
# an associated source, it should respond to `description` that defines
# the contents of the label.
#
class Adjustment < ApplicationRecord

  monetize :amount_cents, allow_nil: true

  #---
  belongs_to :adjustable, polymorphic: true
  belongs_to :source, polymorphic: true

  delegate :tax_rate, :price_includes_tax?, to: :adjustable

  scope :credit, -> { where('amount_cents <= ?', 0) }
  scope :charge, -> { where('amount_cents > ?', 0) }

  #---
  def credit?
    amount_cents.nil? || amount_cents < 0
  end

  def charge?
    amount_cents.present? && amount_cents > 0
  end

  def amount_sans_tax
    amount_as_price.sans_tax
  end

  def tax
    amount_as_price.tax
  end

  def amount_with_tax
    amount_as_price.with_tax
  end

  def validity_last_date
    source.present? && source.last_date.presence
  end

  private
    def amount_as_price
      @amount_as_price ||= Price.new(amount, price_includes_tax?, tax_rate)
    end
end
