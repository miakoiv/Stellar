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
    def apply!(order, items)
      items_by_price = flatten(items.unscope(:order).order(price_cents: :desc))
      items_by_price.each_slice(required_items) do |bundle|
        break if bundle.size < required_items
        last_item = bundle.last
        promoted_item = promotion.item_from_order_item(last_item)
        product_titles = bundle.map(&:product).to_sentence
        last_item.adjustments.create(
          source: promoted_item,
          label: "#{promoted_item.description} (#{product_titles})",
          amount: (last_item.price || 0) * discount_percent/-100
        )
      end
    end

    def editable_prices?
      false
    end

    def to_partial_path
      'admin/promotion_handler/freebie_bundle'
    end
  end
end
