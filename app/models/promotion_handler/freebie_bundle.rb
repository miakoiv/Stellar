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
    # Freebies in bundles are found by flattening and sorting the items
    # by descending price and adding an adjustment to the last one.
    # The order decides the tax treatment used for sorting.
    def apply!(order, items)
      price_method = order.includes_tax? ? :price_with_tax : :price_sans_tax

      items_by_price = flatten(items).sort { |a, b|
        b.send(price_method) <=> a.send(price_method)
      }

      items_by_price.each_slice(required_items) do |bundle|
        break if bundle.size < required_items
        last_item = bundle.last
        promoted_item = promotion.item_from_order_item(last_item)
        last_item.adjustments.create(
          source: promoted_item,
          label: promoted_item.description,
          amount: (last_item.price || 0.to_money) * discount_percent/-100
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
