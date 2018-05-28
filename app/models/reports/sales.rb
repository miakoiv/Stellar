module Reports

  class Sales

    def initialize(search)
      @sort = search.raw_options[:sort]
      @items = search.results
    end

    def by_date
      @by_date ||= @items.select(
        'ordered_at AS date,
        SUM(amount) AS amount, SUM(total_sans_tax_cents) AS value_sans_tax'
      ).group(:ordered_at).reorder(:ordered_at)
    end

    def by_product
      @items.select(
        'products.id AS product_id, products.code AS product_code,
        products.title AS product_title, products.subtitle AS product_subtitle,
        SUM(amount) AS amount, SUM(total_sans_tax_cents) AS value_sans_tax'
      ).group(:product_id).reorder(@sort)
    end

    def by_tax_rate
      @items.select(
        'tax_rate, SUM(amount) AS amount,
        SUM(total_sans_tax_cents) AS value_sans_tax,
        SUM(total_with_tax_cents) AS value_with_tax,
        SUM(total_tax_cents) AS value_tax'
      ).group(:tax_rate)
    end

    def grand_total_sans_tax
      @items.sum(:total_sans_tax_cents)
    end

    def unit_count
      @items.sum(:amount)
    end

    def product_count
      @items.distinct.count(:product_id)
    end
  end
end
