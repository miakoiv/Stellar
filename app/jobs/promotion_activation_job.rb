# When a promotion becomes active (or inactive), this job resets
# the promoted price of all affected products.
#
class PromotionActivationJob < ActiveJob::Base
  queue_as :default

  def perform(promotion)
    promotion.products.each do |product|
      product.reset_promoted_price!
    end
  end
end
