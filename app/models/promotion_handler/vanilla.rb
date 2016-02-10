#encoding: utf-8

class PromotionHandler
  class Vanilla < PromotionHandler

    #---
    def apply!(order)
      logger.info "Applying #{promotion} to order #{order}"
    end

    def editable_prices?
      true
    end

    def to_partial_path
      'admin/promotion_handler/vanilla'
    end
  end
end
