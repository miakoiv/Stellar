#encoding: utf-8

class PromotionHandler
  class BundlePricing < PromotionHandler

    monetize :items_total_cents, allow_nil: true

    validates :required_items,
      numericality: {only_integer: true, greater_than: 1},
      on: :update
    validates :items_total_cents,
      numericality: {greater_than: 0},
      on: :update

    #---
    def apply!(order, items)
      items_by_price = flatten(items.unscope(:order).order(price_cents: :desc))
      items_by_price.each_slice(required_items) do |bundle|
        break if bundle.size < required_items
        product_titles = bundle.map(&:product).to_sentence
        bundle_total = bundle.map { |item| item.price || 0 }.sum
        order.adjustments.create(
          source: promotion,
          label: "#{promotion.description} (#{product_titles})",
          amount: [items_total - bundle_total, 0].min
        )
      end
    end

    def editable_prices?
      false
    end

    def to_partial_path
      'admin/promotion_handler/bundle_pricing'
    end
  end
end
