#encoding: utf-8

class PromotionFreebieBundle < PromotionHandler

  validates :required_items,
    numericality: {only_integer: true, greater_than: 1},
    on: :update
  validates :discount_percent,
    numericality: {
      only_integer: true,
      greater_than: 0,
      less_than_or_equal_to: 100
    }, on: :update

    #---
    def apply!(order)
      logger.info "Applying #{self} to order #{order}"
    end
end
