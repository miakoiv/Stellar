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
    # Bundle prices are achieved by sorting the items by descending price,
    # picking up bundles of items, and adding an adjustment to each item
    # proportionally, totalling the difference between bundle subtotal and
    # the target price set by the promotion.
    def apply!(order, items)
      tax_included = order.includes_tax?
      price_method = tax_included ? :price_with_tax : :price_sans_tax
      subtotal_method = tax_included ? :subtotal_with_tax : :subtotal_sans_tax

      items_by_price = flatten(items).sort { |a, b|
        b.send(price_method) <=> a.send(price_method)
      }

      items_by_price.each_slice(required_items) do |slice|
        break if slice.size < required_items
        bundle = recombine(slice)
        subtotals = {}
        bundle_total = bundle.map { |item|
          subtotals[item.id] = item.send(subtotal_method)
        }.sum
        difference = items_total - bundle_total
        applied = 0.to_money
        product_titles = bundle.map(&:product).to_sentence

        bundle.each_with_index do |item, i|

          # The last item gets the remainder to avoid rounding errors.
          # Others calculate a portion and add it to applied amounts.
          amount = if i == bundle.count - 1
            difference - applied
          else
            subtotals[item.id] / bundle_total * difference
          end
          applied += amount

          # Discount as a Price object to include taxation metadata.
          discount = Price.new(amount, tax_included, item.tax_rate)
          item.adjustments.create(
            source: promotion,
            label: "#{promotion.description} (#{product_titles})",
            amount: item.price_includes_tax? ? discount.with_tax : discount.sans_tax
          )
        end
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
