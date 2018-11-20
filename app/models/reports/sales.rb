module Reports

  class Sales

    TEMPORAL_UNITS = %w{day week month}.freeze

    def initialize(search)
      @unit = search.options['temporal_unit']
      @sort = search.raw_options[:sort]
      @items = search.results
    end

    def by_product
      @items.select(
        'products.id AS product_id, products.code AS product_code,
        products.title AS product_title, products.subtitle AS product_subtitle,
        tax_rate, SUM(amount) AS amount,
        SUM(total_sans_tax_cents) AS value_sans_tax,
        SUM(total_with_tax_cents) AS value_with_tax,
        SUM(total_tax_cents) AS value_tax'
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

    def temporal_data
      @temporal_data ||= send("by_#{@unit}")
    end

    def units_max
      temporal_data.map(&:amount).max
    end

    def product_count
      @items.distinct.count(:product_id)
    end

    private
      # Temporal data gathering methods, called by #temporal_data.
      def by_day
        @items.select(
          'ordered_at AS datum,
          SUM(amount) AS amount, SUM(total_sans_tax_cents) AS value_sans_tax'
        ).group('datum').reorder('datum')
      end

      def by_week
        @items.select(
          "DATE_FORMAT(ordered_at, '%xW%v') AS datum,
          SUM(amount) AS amount, SUM(total_sans_tax_cents) AS value_sans_tax"
        ).group('datum').reorder('datum')
      end

      def by_month
        @items.select(
          "DATE_FORMAT(ordered_at, '%Y-%m') AS datum,
          SUM(amount) AS amount, SUM(total_sans_tax_cents) AS value_sans_tax"
        ).group('datum').reorder('datum')
      end
  end
end
