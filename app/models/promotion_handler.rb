#encoding: utf-8
#
# PromotionHandler is the parent class of different promotion handlers
# with varying business logic for how to apply the promotion on a given
# order.
#
# Promotion handlers are predefined and loaded from fixtures. Therefore
# there are no associated controllers or views.
#
class PromotionHandler < ActiveRecord::Base

  def to_s
    name
  end
end
