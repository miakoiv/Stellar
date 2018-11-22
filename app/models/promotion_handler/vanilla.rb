#encoding: utf-8

class PromotionHandler
  class Vanilla < PromotionHandler

    def apply!(order, items)
      items.each do |item|
        promoted_item = promotion.item_from_order_item(item)
        discount = promoted_item.price - item.price
        item.adjustments.create(
          source: promotion,
          label: promoted_item.description,
          amount: item.amount * discount
        )
      end
    end

    def editable_prices?
      true
    end

    def to_partial_path
      'promotion_handler/vanilla'
    end
  end
end
