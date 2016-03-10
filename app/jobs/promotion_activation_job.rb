#
# When a promotion becomes active (or inactive), this job touches
# all the affected products to invalidate their cached views.
#
class PromotionActivationJob < ActiveJob::Base
  queue_as :default

  def perform(promotion)
    promotion.products.each do |product|
      product.touch
    end
  end
end
