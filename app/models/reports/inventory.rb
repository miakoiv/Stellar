module Reports

  class Inventory

    def initialize(search)
      @items = search.results.reorder(search.raw_options[:sort])
    end

    def with_subtotals
      @items.select <<-SQL
        products.id AS product_id, products.code AS product_code,
        products.title AS product_title, products.subtitle AS product_subtitle,
        on_hand, value_cents AS unit_value,
        value_cents * GREATEST(0, on_hand) AS subtotal_value
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
