#encoding: utf-8

class PromotionHandler
  class FreebieBundle < PromotionHandler

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
      logger.info "Applying #{promotion} to order #{order}"
    end

    def editable_prices?
      false
    end

    def to_partial_path
      'admin/promotion_handler/freebie_bundle'
    end
  end
end
