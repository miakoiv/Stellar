#encoding: utf-8
#
# PromotionHandler is the parent class of different promotion handlers
# with varying business logic for how to apply the promotion on a given
# order.
#
class PromotionHandler < ActiveRecord::Base

  belongs_to :promotion

  #---
  validates :description, presence: true, on: :update

end
