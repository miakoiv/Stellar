#encoding: utf-8

class PromotionHandler
  class Vanilla < PromotionHandler

    # Vanilla promotions do not apply adjustments since order items
    # are created with the promoted price.
    def apply!(order, items)
    end

    def editable_prices?
      true
    end

    def to_partial_path
      'promotion_handler/vanilla'
    end
  end
end
