#encoding: utf-8
#
# PromotedItem links a product to a promotion and keeps track of units
# sold through the promotion. The amount of units available can be declared.
#
class PromotedItem < ActiveRecord::Base

  belongs_to :promotion
  belongs_to :product

end
