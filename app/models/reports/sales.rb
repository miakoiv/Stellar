module Reports

  class Sales

    TEMPORAL_UNITS = %w{day week month}.freeze

    def initialize(search)
      @unit = search.options['temporal_unit']
      @sort = search.raw_options[:sort]
      @items = search.results
    end

    def by_product
      @items.select(<<~SQL).group(:product_id, :tax_rate).reorder(@sort)
        products.id AS product_id, products.code AS product_code,
        products.title AS product_title, products.subtitle AS product_subtitle,
        tax_rate, SUM(amount) AS amount,
        SUM(total_sans_tax_cents) AS value_sans_tax,
        SUM(total_with_tax_cents) AS value_with_tax,
        SUM(total_tax_cents) AS value_tax
      SQL
    end

    def by_tax_rate
      @items.select(<<~SQL).group(:tax_rate)
        tax_rate, SUM(amount) AS amount,
        SUM(total_sans_tax_cents) AS value_sans_tax,
        SUM(total_with_tax_cents) AS value_with_tax,
        SUM(total_tax_cents) AS value_tax
      SQL
    end

    def best_selling(top = 10)
      @items.select('products.id AS product_id').group(:product_id)
        .reorder('SUM(amount) DESC')
        .first(top)
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
        @items.select(<<~SQL).group('datum').reorder('datum')
          ordered_at AS datum,
          SUM(amount) AS amount,
          SUM(total_sans_tax_cents) AS value_sans_tax
        SQL
      end

      def by_week
        @items.select(<<~SQL).group('datum').reorder('datum')
          DATE_FORMAT(ordered_at, '%xW%v') AS datum,
          SUM(amount) AS amount,
          SUM(total_sans_tax_cents) AS value_sans_tax
        SQL
      end

      def by_month
        @items.select(<<~SQL).group('datum').reorder('datum')
          DATE_FORMAT(ordered_at, '%Y-%m') AS datum,
          SUM(amount) AS amount,
          SUM(total_sans_tax_cents) AS value_sans_tax
        SQL
      end
  end
end
