module Reports

  class Inventory

    def initialize(search)
      @items = search.results.reorder(search.raw_options[:sort])
    end

    def with_subtotals
      @items.select(<<~SQL).group(:product_id)
        products.id AS product_id, products.code AS product_code,
        products.title AS product_title, products.subtitle AS product_subtitle,
        SUM(on_hand) AS on_hand,
        SUM(value_cents * on_hand) / SUM(on_hand) AS unit_value,
        GREATEST(0, SUM(value_cents * on_hand)) AS subtotal_value
      SQL
    end

    def grand_total
      @items.sum('value_cents * GREATEST(0, on_hand)')
    end

    def product_count
      @items.distinct.count(:product_id)
    end
  end
end
