# When a promotion is activated or deactivated, this job touches
# the affected products to bust their fragment caches.
class PromotionActivationJob < ActiveJob::Base
  queue_as :default

  def perform(promotion)
    promotion.touch_products
  end
end
