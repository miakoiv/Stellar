#encoding: utf-8

class PromotionHandler
  class BulkDiscount < PromotionHandler

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
    def apply!(order, items)
      p = 1 - discount_percent / 100.0
      b = required_items
      items.each do |item|
        next if (n = item.amount) < b || item.price.nil?
        promoted_item = promotion.item_from_order_item(item)
        m = 1 - p ** (n / b) # integer division
        item.adjustments.create(
          source: promoted_item,
          label: promoted_item.description,
          amount: -n * m * item.price
        )
      end
    end

    def editable_prices?
      false
    end

    def to_partial_path
      'admin/promotion_handler/bulk_discount'
    end
  end
end
