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

  #---
  belongs_to :adjustable, polymorphic: true
  belongs_to :source, polymorphic: true

  scope :credit, -> { where('amount_cents <= ?', 0) }
  scope :charge, -> { where('amount_cents > ?', 0) }

  #---
  def credit?
    amount_cents.nil? || amount_cents < 0
  end

  def charge?
    amount_cents.present? && amount_cents > 0
  end
end
