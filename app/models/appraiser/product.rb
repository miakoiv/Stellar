#encoding: utf-8

module Appraiser

  # Product appraiser is set up with a group and
  # given products to appraise as Price objects.
  class Product

    attr_accessor :group

    def initialize(group)
      @group = group
    end

    # Final price to use for order items.
    def for_order(product)
      final_price(product)
    end

    # Price used for display purposes, including any aggregated
    # component prices for bundle or composite products.
    # Returns a tuple of final price, regular price, where the latter
    # only appears if there was a special price.
    def for_display(product)
      if product.bundle? || product.composite?
        [aggregate_price(product), nil]
      else
        if special = special_price(product)
          [special, regular_price(product)]
        else
          [regular_price(product), nil]
        end
      end
    end

    # Price range to display for a product with variants. Final prices
    # are taken from tuples returned by #for_display and minmaxed.
    def range_for_display(product)
      return nil unless product.has_variants?
      product.variants.live.map { |variant| for_display(variant).first }
        .reject(&:nil?).minmax
    end

    private
      # Base price from product attributes.
      def base_price(product)
        price(product, product.send(group.price_method))
      end

      # In the absence of alternate pricing for this group,
      # the base price is adjusted by group price modifier.
      def regular_price(product)
        alternate = product.alternate_prices.for(group)
        if alternate.present?
          price(product, alternate.price)
        else
          base_price(product).modify!(group.price_modifier)
        end
      end

      # Picks the lowest price from promotions.
      def special_price(product)
        lowest = product.best_promoted_item(group)
        return nil if lowest.nil?
        price(product, lowest.price)
      end

      # Final price appearing on order items, see #for_order.
      # Special price always takes precedence over regular price,
      # no matter which is lower -- promotions are able to raise prices.
      def final_price(product)
        special_price(product) || regular_price(product)
      end

      # Aggregate price includes bundle/composite components.
      def aggregate_price(product)
        if product.bundle?
          component_total_price(product)
        elsif product.composite?
          final_price(product) + component_total_price(product)
        else
          final_price(product)
        end
      end

      # Total price of components. This is added to composite product
      # prices, and bundle prices consist solely of component totals.
      # Final price is used for the sum, therefore bundle and composite
      # prices may change due to group pricing or promotions.
      def component_total_price(product)
        entries = product.component_entries
        return Price.zero if entries.empty?
        entries.map { |entry|
          final_price(entry.component) * entry.quantity
        }.sum
      end

      # Convenience method for creating price objects.
      def price(product, amount)
        Price.new(
          amount,
          product.tax_category.tax_included?(group.price_base),
          product.tax_category.rate
        )
      end
  end
end
