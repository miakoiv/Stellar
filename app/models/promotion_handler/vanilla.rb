#encoding: utf-8

class PromotionHandler
  class Vanilla < PromotionHandler

    #---
    def apply!(order_items)
      order_items.each do |order_item|
        promoted_item = promotion.promoted_items.includes(:product).find_by(product_id: order_item.product_id)
        order_item.adjustments.create(
          source: promoted_item,
          label: promoted_item.description,
          amount: order_item.amount * (promoted_item.price - order_item.price)
        )
      end
    end

    def editable_prices?
      true
    end

    def to_partial_path
      'admin/promotion_handler/vanilla'
    end
  end
end
