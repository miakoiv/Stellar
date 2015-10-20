#encoding: utf-8
#
# Adjustments are modifiers affecting the price of an adjustable object.
# Anything adjustable may have an adjustment that adds amount_cents to its
# price. The attached label provides detailed information.
# If an adjustment has an associated source, it should respond to
# `adjustment_label` that defines the contents of the label.
#
class Adjustment < ActiveRecord::Base
  belongs_to :adjustable, polymorphic: true
  belongs_to :source, polymorphic: true

  monetize :amount_cents
end
